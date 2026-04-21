const { createPrismaMock } = require('./helpers/prismaMock');

const mockPrisma = createPrismaMock();
jest.mock('../../../CoursePSKP/server/src/config/prisma', () => mockPrisma);

jest.mock(
  'qrcode',
  () => ({
    toDataURL: jest.fn(async () => 'data:image/png;base64,STUB_QR'),
  }),
  { virtual: true }
);

const VisitService = require('../../../CoursePSKP/server/src/services/visitService');
const QRCode = require('qrcode');

describe('VisitService.getMyQR — генерация QR-кода клиента', () => {
  const USER_ID = 77;

  test('возвращает qrToken пользователя и data URL изображения', async () => {
    mockPrisma.user.findUnique.mockResolvedValue({ qrToken: 'token-abc-123' });

    const result = await VisitService.getMyQR(USER_ID);

    expect(result.qrToken).toBe('token-abc-123');
    expect(result.qrDataUrl).toBe('data:image/png;base64,STUB_QR');

    expect(QRCode.toDataURL).toHaveBeenCalledWith(
      'token-abc-123',
      expect.objectContaining({ width: 300, margin: 2 })
    );
  });

});

describe('VisitService.checkIn — регистрация посещения по QR', () => {
  const ADMIN_ID = 1;
  const QR_TOKEN = 'token-abc-123';

  test('успешно регистрирует визит и уменьшает remainingSessions', async () => {

    mockPrisma.user.findFirst.mockResolvedValue({ id: 77 });
    mockPrisma.userSubscription.findFirst.mockResolvedValue({
      id: 500,
      remainingSessions: 10,
    });

    mockPrisma.visit.create.mockResolvedValue({ id: 9000, userId: 77 });
    mockPrisma.userSubscription.update.mockResolvedValue({});

    mockPrisma.user.findUnique.mockResolvedValue({ firstName: 'Иван', lastName: 'Иванов' });

    const result = await VisitService.checkIn(QR_TOKEN, ADMIN_ID);

    expect(result.client).toEqual({ first_name: 'Иван', last_name: 'Иванов' });
    expect(result.remainingSessions).toBe(9);
    expect(mockPrisma.visit.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ userId: 77, checkedBy: ADMIN_ID }),
      })
    );
  });

  test('бросает 404, если по QR-токену клиент не найден', async () => {
    mockPrisma.user.findFirst.mockResolvedValue(null);

    await expect(VisitService.checkIn('invalid', ADMIN_ID)).rejects.toMatchObject({
      message: 'Клиент не найден по QR-коду',
      status: 404,
    });
  });

  test('бросает 400, если у клиента нет активного абонемента', async () => {
    mockPrisma.user.findFirst.mockResolvedValue({ id: 77 });
    mockPrisma.userSubscription.findFirst.mockResolvedValue(null);

    await expect(VisitService.checkIn(QR_TOKEN, ADMIN_ID)).rejects.toMatchObject({
      message: 'У клиента нет активного абонемента',
      status: 400,
    });
    expect(mockPrisma.visit.create).not.toHaveBeenCalled();
  });

  test('безлимитный абонемент (remainingSessions = null) — визит проходит, не декрементируется', async () => {
    mockPrisma.user.findFirst.mockResolvedValue({ id: 77 });
    mockPrisma.userSubscription.findFirst.mockResolvedValue({
      id: 500,
      remainingSessions: null,
    });
    mockPrisma.visit.create.mockResolvedValue({ id: 9001 });
    mockPrisma.user.findUnique.mockResolvedValue({ firstName: 'Пётр', lastName: 'Петров' });

    const result = await VisitService.checkIn(QR_TOKEN, ADMIN_ID);

    expect(result.remainingSessions).toBeNull();
    expect(mockPrisma.userSubscription.update).not.toHaveBeenCalled();
  });
});
