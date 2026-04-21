const { createPrismaMock } = require('./helpers/prismaMock');

const mockPrisma = createPrismaMock();
jest.mock('../../../CoursePSKP/server/src/config/prisma', () => mockPrisma);

const SubscriptionService = require('../../../CoursePSKP/server/src/services/subscriptionService');

describe('SubscriptionService.purchase — покупка абонемента', () => {
  const USER_ID = 42;
  const PLAN_ID = 7;

  test('успешно покупает абонемент и создаёт userSubscription с корректными датами', async () => {
    mockPrisma.subscription.findFirst.mockResolvedValue({
      id: PLAN_ID,
      status: 'active',
      durationDays: 30,
      totalSessions: 12,
    });
    mockPrisma.userSubscription.findFirst.mockResolvedValue(null);
    mockPrisma.userSubscription.create.mockImplementation(async ({ data }) => ({
      id: 500,
      userId: data.userId,
      subscriptionId: data.subscriptionId,
      startDate: data.startDate,
      endDate: data.endDate,
      totalSessions: data.totalSessions,
      remainingSessions: data.remainingSessions,
      status: 'active',
    }));

    const result = await SubscriptionService.purchase(USER_ID, PLAN_ID);

    expect(result.user_id).toBe(USER_ID);
    expect(result.subscription_id).toBe(PLAN_ID);
    expect(result.total_sessions).toBe(12);
    expect(result.remaining_sessions).toBe(12);
    const diffDays = Math.round(
      (new Date(result.end_date) - new Date(result.start_date)) / (1000 * 60 * 60 * 24)
    );
    expect(diffDays).toBe(30);
  });

  test('бросает 404, если абонемент не найден или архивирован', async () => {
    mockPrisma.subscription.findFirst.mockResolvedValue(null);

    await expect(SubscriptionService.purchase(USER_ID, PLAN_ID)).rejects.toMatchObject({
      message: 'Абонемент не найден или недоступен',
      status: 404,
    });
    expect(mockPrisma.userSubscription.create).not.toHaveBeenCalled();
  });

});

describe('SubscriptionService.freeze — заморозка абонемента', () => {
  const USER_ID = 42;
  const US_ID = 500;

  test('успешно замораживает абонемент на 10 дней, сдвигая endDate', async () => {
    const originalEnd = new Date('2026-06-01T00:00:00Z');
    mockPrisma.userSubscription.findFirst.mockResolvedValue({
      id: US_ID,
      userId: USER_ID,
      status: 'active',
      endDate: originalEnd,
      subscription: { maxFreezeDays: 14 },
    });
    mockPrisma.subscriptionFreeze.aggregate.mockResolvedValue({ _sum: { daysUsed: 0 } });
    mockPrisma.subscriptionFreeze.create.mockResolvedValue({});
    mockPrisma.userSubscription.update.mockResolvedValue({});

    const result = await SubscriptionService.freeze(USER_ID, US_ID, 10);

    expect(result.days).toBe(10);
    const diff = Math.round(
      (new Date(result.newEndDate) - originalEnd) / (1000 * 60 * 60 * 24)
    );
    expect(diff).toBe(10);
    expect(mockPrisma.$transaction).toHaveBeenCalledTimes(1);
  });

  test('бросает 400, если у абонемента нет опции заморозки (maxFreezeDays = null)', async () => {
    mockPrisma.userSubscription.findFirst.mockResolvedValue({
      id: US_ID,
      userId: USER_ID,
      status: 'active',
      endDate: new Date(),
      subscription: { maxFreezeDays: null },
    });

    await expect(SubscriptionService.freeze(USER_ID, US_ID, 5)).rejects.toMatchObject({
      message: 'Этот абонемент нельзя заморозить',
      status: 400,
    });
  });

  test('бросает 400, если запрошенная заморозка превышает оставшийся лимит', async () => {
    mockPrisma.userSubscription.findFirst.mockResolvedValue({
      id: US_ID,
      userId: USER_ID,
      status: 'active',
      endDate: new Date(),
      subscription: { maxFreezeDays: 14 },
    });
    mockPrisma.subscriptionFreeze.aggregate.mockResolvedValue({ _sum: { daysUsed: 10 } });

    await expect(SubscriptionService.freeze(USER_ID, US_ID, 7)).rejects.toMatchObject({
      message: expect.stringContaining('Максимум заморозки: 14'),
      status: 400,
    });
    expect(mockPrisma.subscriptionFreeze.create).not.toHaveBeenCalled();
  });
});
