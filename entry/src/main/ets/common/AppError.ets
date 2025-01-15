export class AppError extends Error {
  public readonly code: number;
  public readonly msg: string;

  constructor(code: number, message: string) {
    super(message);
    this.msg = message || "Unknown error";
    this.code = code;
  }
}