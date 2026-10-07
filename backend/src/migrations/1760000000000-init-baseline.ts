import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitBaseline1760000000000 implements MigrationInterface {
  name = 'InitBaseline1760000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Mốc khởi tạo (Baseline): DB hiện tại đã chuẩn theo toàn bộ Entity trong source code.
    // Các thay đổi schema trong tương lai sẽ tạo migration mới tiếp theo từ mốc này.
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Baseline root - không rollback
  }
}
