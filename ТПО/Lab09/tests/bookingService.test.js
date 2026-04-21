const { createPrismaMock } = require('./helpers/prismaMock');

const mockPrisma = createPrismaMock();
jest.mock('../../../CoursePSKP/server/src/config/prisma', () => mockPrisma);

const BookingService = require('../../../CoursePSKP/server/src/services/bookingService');

const prismaMock = mockPrisma;

describe('BookingService.book — запись на тренировку', () => {
  const USER_ID = 10;
  const TRAINING_ID = 100;

  test('успешно создаёт бронь, когда есть места и абонемент активен', async () => {
    const futureDate = new Date(Date.now() + 60 * 60 * 1000);
    prismaMock.training.findUnique.mockResolvedValue({
      id: TRAINING_ID,
      availableSlots: 5,
      startTime: futureDate,
    });
    prismaMock.userSubscription.findFirst.mockResolvedValue({ id: 777 });
    prismaMock.booking.create.mockResolvedValue({
      id: 1,
      userId: USER_ID,
      trainingId: TRAINING_ID,
      userSubscriptionId: 777,
      status: 'booked',
      createdAt: new Date('2026-04-17'),
    });
    prismaMock.training.update.mockResolvedValue({});

    const result = await BookingService.book(USER_ID, TRAINING_ID);

    expect(result.status).toBe('booked');
    expect(result.user_id).toBe(USER_ID);
    expect(result.training_id).toBe(TRAINING_ID);
    expect(result.user_subscription_id).toBe(777);

    expect(prismaMock.$transaction).toHaveBeenCalledTimes(1);
  });

  test('бросает 404 "Тренировка не найдена", если тренировки нет в БД', async () => {
    prismaMock.training.findUnique.mockResolvedValue(null);

    await expect(BookingService.book(USER_ID, TRAINING_ID)).rejects.toMatchObject({
      message: 'Тренировка не найдена',
      status: 404,
    });

    expect(prismaMock.booking.create).not.toHaveBeenCalled();
  });

  test('бросает 400 "Нет свободных мест", если availableSlots = 0', async () => {
    prismaMock.training.findUnique.mockResolvedValue({
      id: TRAINING_ID,
      availableSlots: 0,
      startTime: new Date(Date.now() + 60000),
    });

    await expect(BookingService.book(USER_ID, TRAINING_ID)).rejects.toMatchObject({
      message: 'Нет свободных мест',
      status: 400,
    });
  });

  test('бросает 409, если пользователь уже записан (P2002 — unique constraint)', async () => {
    prismaMock.training.findUnique.mockResolvedValue({
      id: TRAINING_ID,
      availableSlots: 5,
      startTime: new Date(Date.now() + 60000),
    });
    prismaMock.userSubscription.findFirst.mockResolvedValue(null);
    prismaMock.$transaction.mockRejectedValueOnce(
      Object.assign(new Error('Unique constraint'), { code: 'P2002' })
    );

    await expect(BookingService.book(USER_ID, TRAINING_ID)).rejects.toMatchObject({
      message: 'Вы уже записаны на эту тренировку',
      status: 409,
    });
  });
});

describe('BookingService.cancel — отмена записи', () => {
  const USER_ID = 10;
  const BOOKING_ID = 55;

  test('успешно отменяет запись на будущую тренировку', async () => {
    prismaMock.booking.findFirst.mockResolvedValue({
      id: BOOKING_ID,
      userId: USER_ID,
      status: 'booked',
      training: {
        id: 100,
        startTime: new Date(Date.now() + 60 * 60 * 1000),
      },
    });

    const result = await BookingService.cancel(USER_ID, BOOKING_ID);

    expect(result).toEqual({ message: 'Запись отменена' });
    expect(prismaMock.$transaction).toHaveBeenCalledTimes(1);
  });

});
