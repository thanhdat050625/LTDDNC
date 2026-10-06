import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { CreateMovieRequestDto, UpdateMovieRequestDto } from './dto/movie.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Movie } from './entities/movie.entity';
import { Brackets, FindOptionsOrder, FindOptionsWhere, In, Repository } from 'typeorm';
import { EMovieStatus } from './enums/movie.enum';
import { ApiResponse } from '../../core/dto/ApiResponse.dto';
import { CloudinaryService } from '../cloudinary/cloudinary.service';

@Injectable()
export class MovieService {
  constructor(
    @InjectRepository(Movie)
    private readonly movieRepository: Repository<Movie>,
    private readonly cloudinaryService: CloudinaryService,
  ) {}

  async createMovie(
    request: CreateMovieRequestDto,
    poster?: Express.Multer.File,
  ) {
    const title = (request.title || request.name || '').trim();
    if (!title) {
      throw new BadRequestException('Tên phim không được để trống');
    }

    const posterUrl = await this.resolvePosterUrl(request, poster);

    const newMovie = this.movieRepository.create({
      title,
      description: request.description,
      status: (request.status as EMovieStatus) || EMovieStatus.COMING_SOON,
      posterUrl,
      trailerUrl: request.trailerUrl,
      durationMinutes: request.durationMinutes ?? request.duration ?? 0,
      releaseDate: request.releaseDate,
      screeningEndDate: request.screeningEndDate,
      genre: request.genre,
      director: request.director,
      cast: request.cast ?? (request.actors ? request.actors.join(', ') : ''),
      language: request.language,
      ageLimit: request.ageLimit,
    });

    const savedMovie = await this.movieRepository.save(newMovie);
    return new ApiResponse(true, 'Tạo phim mới thành công', savedMovie);
  }

  async updateMovie(
    id: number,
    request: UpdateMovieRequestDto,
    poster?: Express.Multer.File,
  ) {
    const movie = await this.movieRepository.findOne({ where: { id } });
    if (!movie) {
      throw new NotFoundException('Không tìm thấy phim');
    }

    const posterUrl = await this.resolvePosterUrl(request, poster, movie.posterUrl);

    const updatedMovie = Object.assign(movie, {
      title: request.title ?? request.name ?? movie.title,
      description: request.description ?? movie.description,
      status: request.status ? (request.status as EMovieStatus) : movie.status,
      posterUrl,
      trailerUrl: request.trailerUrl ?? movie.trailerUrl,
      durationMinutes: request.durationMinutes ?? request.duration ?? movie.durationMinutes,
      releaseDate: request.releaseDate ?? movie.releaseDate,
      screeningEndDate: request.screeningEndDate !== undefined ? request.screeningEndDate : movie.screeningEndDate,
      genre: request.genre ?? movie.genre,
      director: request.director ?? movie.director,
      cast: request.cast ?? (request.actors ? request.actors.join(', ') : movie.cast),
      language: request.language ?? movie.language,
      ageLimit: request.ageLimit ?? movie.ageLimit,
    });

    await this.movieRepository.save(updatedMovie);

    return new ApiResponse(true, 'Cập nhật phim thành công', updatedMovie);
  }

  async deleteMovie(id: number) {
    const movie = await this.movieRepository.findOne({ where: { id } });
    if (!movie) {
      throw new NotFoundException('Không tìm thấy phim');
    }

    await this.movieRepository.remove(movie);
    return new ApiResponse(true, 'Xóa phim thành công');
  }

  async getMovie(id: number) {
    const movie = await this.movieRepository.findOne({ where: { id } });
    if (!movie) {
      throw new NotFoundException('Không tìm thấy phim');
    }

    return new ApiResponse(true, 'Lấy thông tin phim thành công', movie);
  }

  async getAllMovies(
    page: number,
    pageSize: number,
    sortBy: string,
    genres: string[],
    search?: string,
    status?: string,
  ) {
    const skip = (page - 1) * pageSize;
    const qb = this.movieRepository.createQueryBuilder('movie');

    if (search && search.trim()) {
      qb.andWhere('LOWER(movie.title) LIKE :search', {
        search: `%${search.trim().toLowerCase()}%`,
      });
    }

    if (status && status !== 'ALL' && status !== 'Tất cả') {
      qb.andWhere('movie.status = :status', { status });
    }

    if (genres && genres.length > 0) {
      const genreList = Array.isArray(genres)
        ? genres.filter((g) => g && g !== 'All' && g !== 'Tất cả')
        : typeof genres === 'string' && genres !== 'All' && genres !== 'Tất cả'
          ? (genres as string).split(',').map((g) => g.trim()).filter(Boolean)
          : [];

      if (genreList.length > 0) {
        qb.andWhere(
          new Brackets((bracket) => {
            genreList.forEach((g, idx) => {
              if (idx === 0) {
                bracket.where(`movie.genre LIKE :genre${idx}`, {
                  [`genre${idx}`]: `%${g}%`,
                });
              } else {
                bracket.orWhere(`movie.genre LIKE :genre${idx}`, {
                  [`genre${idx}`]: `%${g}%`,
                });
              }
            });
          }),
        );
      }
    }

    if (sortBy && ['id', 'title', 'releaseDate', 'createdAt'].includes(sortBy)) {
      qb.orderBy(`movie.${sortBy}`, 'DESC');
    } else {
      qb.orderBy('movie.id', 'DESC');
    }

    const [movies, totalItems] = await qb
      .skip(skip)
      .take(pageSize)
      .getManyAndCount();

    const totalPages = Math.ceil(totalItems / pageSize);

    const formattedMovies = movies.map((movie) => ({
      id: movie.id,
      name: movie.title,
      imageUrl: movie.posterUrl,
      posterUrl: movie.posterUrl,
      releaseDate: movie.releaseDate,
      genre: movie.genre,
      director: movie.director,
      cast: movie.cast,
      language: movie.language,
      ageLimit: movie.ageLimit,
      durationMinutes: movie.durationMinutes,
      description: movie.description,
      trailerUrl: movie.trailerUrl,
      status: movie.status,
    }));

    const response = new ApiResponse(
      true,
      'Lấy danh sách phim thành công',
      formattedMovies,
    );
    response.pagination = {
      page: Number(page),
      pageSize: Number(pageSize),
      totalItems,
      totalPages,
    };

    return response;
  }

  private async resolvePosterUrl(
    request: CreateMovieRequestDto | UpdateMovieRequestDto,
    poster?: Express.Multer.File,
    currentPosterUrl?: string,
  ): Promise<string | undefined> {
    if (poster) {
      const uploaded = await this.cloudinaryService.uploadImage(poster);
      return uploaded.secure_url;
    }

    if (request.imageUrl) return request.imageUrl;

    const requestWithPoster = request as UpdateMovieRequestDto & {
      posterUrl?: string;
    };
    if (requestWithPoster.posterUrl) return requestWithPoster.posterUrl;

    return currentPosterUrl;
  }
}
