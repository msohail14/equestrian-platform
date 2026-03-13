import { useState } from 'react';
import { toast } from 'react-hot-toast';
import { BarChart3, TrendingUp, DollarSign, CalendarDays } from 'lucide-react';
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from 'recharts';
import AppButton from '../../components/ui/AppButton';
import FormInput from '../../components/ui/FormInput';
import { getAdminAnalyticsApi } from '../../features/operations/operationsApi';

const AdminAnalyticsPage = () => {
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [loading, setLoading] = useState(false);
  const [analytics, setAnalytics] = useState(null);

  const fetchAnalytics = async () => {
    setLoading(true);
    try {
      const data = await getAdminAnalyticsApi({ startDate, endDate });
      setAnalytics(data?.data || data || null);
    } catch (error) {
      toast.error(error.message || 'Failed to load analytics.');
    } finally {
      setLoading(false);
    }
  };

  const summaryCards = [
    {
      label: 'Total Revenue',
      value: analytics?.total_revenue != null ? `$${Number(analytics.total_revenue).toLocaleString()}` : '-',
      icon: DollarSign,
      accent: 'from-emerald-500 to-teal-500',
    },
    {
      label: 'Total Bookings',
      value: analytics?.total_bookings ?? '-',
      icon: CalendarDays,
      accent: 'from-amber-500 to-orange-500',
    },
  ];

  const riderGrowth = Array.isArray(analytics?.rider_growth) ? analytics.rider_growth : [];
  const bookingVolume = Array.isArray(analytics?.booking_volume) ? analytics.booking_volume : [];
  const revenueData = Array.isArray(analytics?.revenue) ? analytics.revenue : [];

  return (
    <div className="space-y-6">
      <section className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900">
        <div className="mb-4 flex items-center gap-2">
          <BarChart3 size={20} className="text-amber-500" />
          <h2 className="text-xl font-semibold text-gray-900 dark:text-gray-100">Analytics</h2>
        </div>

        <div className="flex flex-wrap items-end gap-3">
          <FormInput
            label="Start Date"
            name="analytics_start"
            type="date"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
          />
          <FormInput
            label="End Date"
            name="analytics_end"
            type="date"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
          />
          <AppButton onClick={fetchAnalytics} disabled={loading}>
            {loading ? 'Loading...' : 'Fetch Analytics'}
          </AppButton>
        </div>
      </section>

      {analytics && (
        <>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            {summaryCards.map((card) => (
              <div
                key={card.label}
                className="group relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-gray-800 dark:bg-gray-900"
              >
                <div className={`absolute inset-x-0 top-0 h-1 bg-gradient-to-r ${card.accent}`} />
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-gray-400">
                      {card.label}
                    </p>
                    <p className="mt-1 text-2xl font-bold text-gray-900 dark:text-white">{card.value}</p>
                  </div>
                  <span className={`inline-flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br ${card.accent} text-white`}>
                    <card.icon size={18} />
                  </span>
                </div>
              </div>
            ))}
          </div>

          {riderGrowth.length > 0 && (
            <section className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900">
              <div className="mb-3 flex items-center gap-2">
                <TrendingUp size={18} className="text-emerald-500" />
                <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Rider Growth</h3>
              </div>
              <div className="h-[300px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={riderGrowth}>
                    <CartesianGrid strokeDasharray="3 3" strokeOpacity={0.25} />
                    <XAxis dataKey="label" tick={{ fontSize: 12 }} interval="preserveStartEnd" />
                    <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
                    <Tooltip />
                    <Area type="monotone" dataKey="count" stroke="#10b981" fill="#10b981" fillOpacity={0.15} strokeWidth={2} />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </section>
          )}

          {bookingVolume.length > 0 && (
            <section className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900">
              <div className="mb-3 flex items-center gap-2">
                <CalendarDays size={18} className="text-amber-500" />
                <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Booking Volume</h3>
              </div>
              <div className="h-[300px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={bookingVolume}>
                    <CartesianGrid strokeDasharray="3 3" strokeOpacity={0.25} />
                    <XAxis dataKey="label" tick={{ fontSize: 12 }} interval="preserveStartEnd" />
                    <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
                    <Tooltip />
                    <Bar dataKey="count" fill="#f59e0b" radius={[8, 8, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </section>
          )}

          {revenueData.length > 0 && (
            <section className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900">
              <div className="mb-3 flex items-center gap-2">
                <DollarSign size={18} className="text-emerald-500" />
                <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Revenue</h3>
              </div>
              <div className="h-[300px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={revenueData}>
                    <CartesianGrid strokeDasharray="3 3" strokeOpacity={0.25} />
                    <XAxis dataKey="label" tick={{ fontSize: 12 }} interval="preserveStartEnd" />
                    <YAxis tick={{ fontSize: 12 }} />
                    <Tooltip />
                    <Area type="monotone" dataKey="amount" stroke="#10b981" fill="#10b981" fillOpacity={0.15} strokeWidth={2} />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </section>
          )}
        </>
      )}
    </div>
  );
};

export default AdminAnalyticsPage;
