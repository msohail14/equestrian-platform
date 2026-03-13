import { useEffect, useMemo, useState, useCallback } from 'react';
import { useSelector } from 'react-redux';
import { Link } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import {
  BookOpen,
  Building2,
  CalendarCheck,
  ClipboardList,
  Clock,
  DollarSign,
  GraduationCap,
  LayoutGrid,
  PawPrint,
  RefreshCw,
  ShieldCheck,
  Trophy,
  TrendingUp,
  Users,
  ArrowUpRight,
  AlertCircle,
} from 'lucide-react';
import {
  Area,
  AreaChart,
  CartesianGrid,
  Cell,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { getAdminDashboardApi } from '../../features/operations/operationsApi';

const emptyDashboard = {
  stats: {
    total_stables: 0,
    active_stables: 0,
    pending_stables: 0,
    total_arenas: 0,
    active_arenas: 0,
    total_horses: 0,
    active_horses: 0,
    total_disciplines: 0,
    active_disciplines: 0,
    total_riders: 0,
    active_riders: 0,
    total_coaches: 0,
    active_coaches: 0,
    unverified_coaches: 0,
    total_courses: 0,
    active_courses: 0,
    total_enrollments: 0,
    active_enrollments: 0,
  },
  enrollment_trends: {
    daily: [],
    weekly: [],
    monthly: [],
  },
};

const formatDateLabel = (raw) => {
  if (!raw) return '-';
  const parsed = new Date(`${raw}T00:00:00`);
  if (Number.isNaN(parsed.getTime())) return raw;
  return parsed.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
};

const formatMonthLabel = (raw) => {
  if (!raw || !raw.includes('-')) return raw || '-';
  const [year, month] = raw.split('-');
  const parsed = new Date(Number(year), Number(month) - 1, 1);
  if (Number.isNaN(parsed.getTime())) return raw;
  return parsed.toLocaleDateString(undefined, { month: 'short', year: '2-digit' });
};

const getGreeting = () => {
  const h = new Date().getHours();
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
};

const formatRelativeTime = (date) => {
  if (!date) return '';
  const diff = Math.floor((Date.now() - date.getTime()) / 60000);
  if (diff < 1) return 'Just now';
  if (diff === 1) return '1 minute ago';
  if (diff < 60) return `${diff} minutes ago`;
  return date.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' });
};

// --- KPI card data ---
const kpiCards = (stats) => [
  {
    label: 'Total Revenue',
    value: stats.total_enrollments,
    subtitle: 'From enrollments',
    icon: DollarSign,
    gradient: 'from-amber-500 to-orange-500',
    bgLight: 'bg-amber-50',
    bgDark: 'dark:bg-amber-950/30',
  },
  {
    label: 'Active Bookings',
    value: 0,
    subtitle: 'Coming soon',
    icon: CalendarCheck,
    gradient: 'from-blue-500 to-indigo-500',
    bgLight: 'bg-blue-50',
    bgDark: 'dark:bg-blue-950/30',
  },
  {
    label: 'Total Riders',
    value: stats.total_riders,
    subtitle: `${stats.active_riders ?? 0} active`,
    icon: Users,
    gradient: 'from-emerald-500 to-teal-500',
    bgLight: 'bg-emerald-50',
    bgDark: 'dark:bg-emerald-950/30',
  },
  {
    label: 'Total Coaches',
    value: stats.total_coaches ?? 0,
    subtitle: `${stats.active_coaches ?? 0} active`,
    icon: GraduationCap,
    gradient: 'from-violet-500 to-purple-500',
    bgLight: 'bg-violet-50',
    bgDark: 'dark:bg-violet-950/30',
  },
];

// --- Entity distribution pie data ---
const DISTRIBUTION_COLORS = ['#f59e0b', '#3b82f6', '#10b981', '#8b5cf6'];

const buildDistributionData = (stats) => [
  { name: 'Stables', value: Number(stats.total_stables || 0) },
  { name: 'Arenas', value: Number(stats.total_arenas || 0) },
  { name: 'Horses', value: Number(stats.total_horses || 0) },
  { name: 'Disciplines', value: Number(stats.total_disciplines || 0) },
];

// --- Reusable mini donut ---
const TotalActiveMiniChart = ({ total, active }) => {
  const data = [
    { name: 'Active', value: Number(active || 0), fill: '#10b981' },
    { name: 'Inactive', value: Math.max(0, Number(total || 0) - Number(active || 0)), fill: '#e5e7eb' },
  ];

  return (
    <div className="h-20 w-20 flex-shrink-0">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={data}
            dataKey="value"
            nameKey="name"
            innerRadius={24}
            outerRadius={36}
            paddingAngle={3}
            strokeWidth={0}
          >
            {data.map((entry) => (
              <Cell key={entry.name} fill={entry.fill} />
            ))}
          </Pie>
          <Tooltip />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
};

// --- Enrollment area chart ---
const EnrollmentAreaChart = ({ data = [], mode = 'daily' }) => {
  const prepared = useMemo(() => {
    if (mode === 'monthly') {
      return data.map((item) => ({ ...item, displayLabel: formatMonthLabel(item.label) }));
    }
    return data.map((item) => ({ ...item, displayLabel: formatDateLabel(item.label) }));
  }, [data, mode]);

  return (
    <div className="h-[320px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={prepared}>
          <defs>
            <linearGradient id="enrollGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#f59e0b" stopOpacity={0.35} />
              <stop offset="95%" stopColor="#f59e0b" stopOpacity={0.02} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" strokeOpacity={0.15} />
          <XAxis dataKey="displayLabel" tick={{ fontSize: 12 }} interval="preserveStartEnd" />
          <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
          <Tooltip
            contentStyle={{
              borderRadius: '0.75rem',
              border: 'none',
              boxShadow: '0 4px 24px rgba(0,0,0,.1)',
              fontSize: '0.875rem',
            }}
          />
          <Area
            type="monotone"
            dataKey="count"
            stroke="#f59e0b"
            strokeWidth={2.5}
            fill="url(#enrollGradient)"
            dot={{ r: 3, fill: '#f59e0b', strokeWidth: 0 }}
            activeDot={{ r: 5, strokeWidth: 0 }}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
};

// --- Main page ---
const AdminDashboardPage = () => {
  const { admin } = useSelector((state) => state.auth);
  const [loading, setLoading] = useState(true);
  const [dashboard, setDashboard] = useState(emptyDashboard);
  const [trendMode, setTrendMode] = useState('daily');
  const [lastRefreshed, setLastRefreshed] = useState(null);

  const fetchDashboard = useCallback(async () => {
    setLoading(true);
    try {
      const data = await getAdminDashboardApi();
      setDashboard({
        stats: { ...emptyDashboard.stats, ...(data?.stats || {}) },
        enrollment_trends: {
          daily: Array.isArray(data?.enrollment_trends?.daily) ? data.enrollment_trends.daily : [],
          weekly: Array.isArray(data?.enrollment_trends?.weekly) ? data.enrollment_trends.weekly : [],
          monthly: Array.isArray(data?.enrollment_trends?.monthly) ? data.enrollment_trends.monthly : [],
        },
      });
      setLastRefreshed(new Date());
    } catch (error) {
      toast.error(error.message || 'Failed to load dashboard.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchDashboard();
  }, [fetchDashboard]);

  const greeting = getGreeting();

  const dateString = new Date().toLocaleDateString(undefined, {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  const chartData = useMemo(
    () =>
      trendMode === 'daily'
        ? dashboard.enrollment_trends.daily
        : trendMode === 'weekly'
          ? dashboard.enrollment_trends.weekly
          : dashboard.enrollment_trends.monthly,
    [trendMode, dashboard.enrollment_trends],
  );

  const distributionData = useMemo(() => buildDistributionData(dashboard.stats), [dashboard.stats]);

  const pendingStables = dashboard.stats.pending_stables ?? 0;
  const unverifiedCoaches = dashboard.stats.unverified_coaches ?? 0;
  const hasPendingActions = pendingStables > 0 || unverifiedCoaches > 0;

  const recentActivity = useMemo(
    () => [
      { label: 'Stables', total: dashboard.stats.total_stables, active: dashboard.stats.active_stables, icon: Building2 },
      { label: 'Arenas', total: dashboard.stats.total_arenas, active: dashboard.stats.active_arenas, icon: LayoutGrid },
      { label: 'Horses', total: dashboard.stats.total_horses, active: dashboard.stats.active_horses, icon: PawPrint },
      { label: 'Disciplines', total: dashboard.stats.total_disciplines, active: dashboard.stats.active_disciplines, icon: Trophy },
      { label: 'Riders', total: dashboard.stats.total_riders, active: dashboard.stats.active_riders, icon: Users },
    ],
    [dashboard.stats],
  );

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-950">
      <div className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
        {/* ── Welcome header ── */}
        <div className="mb-8 flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs font-semibold uppercase tracking-widest text-amber-500 dark:text-amber-400">
              Dashboard
            </p>
            <h1 className="mt-1 text-2xl font-bold text-gray-900 dark:text-white sm:text-3xl">
              {greeting}, {admin?.first_name || 'Admin'} {admin?.last_name || ''}
            </h1>
            <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{dateString}</p>
          </div>

          <div className="flex items-center gap-3">
            {lastRefreshed && (
              <span className="flex items-center gap-1.5 text-xs text-gray-400 dark:text-gray-500">
                <Clock size={13} />
                {formatRelativeTime(lastRefreshed)}
              </span>
            )}
            <button
              type="button"
              onClick={fetchDashboard}
              disabled={loading}
              className="inline-flex items-center gap-1.5 rounded-lg border border-gray-200 bg-white px-3 py-1.5 text-xs font-medium text-gray-600 shadow-sm transition hover:bg-gray-50 disabled:opacity-50 dark:border-gray-700 dark:bg-gray-900 dark:text-gray-300 dark:hover:bg-gray-800"
            >
              <RefreshCw size={13} className={loading ? 'animate-spin' : ''} />
              Refresh
            </button>
          </div>
        </div>

        {/* ── Loading skeleton ── */}
        {loading && (
          <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            {[...Array(4)].map((_, i) => (
              <div
                key={i}
                className="h-32 animate-pulse rounded-2xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900"
              />
            ))}
          </div>
        )}

        {/* ── KPI row ── */}
        {!loading && (
          <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            {kpiCards(dashboard.stats).map((card) => (
              <div
                key={card.label}
                className="group relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-gray-800 dark:bg-gray-900"
              >
                <div className={`absolute inset-x-0 top-0 h-1 bg-gradient-to-r ${card.gradient}`} />

                <div className="mb-3 flex items-center justify-between">
                  <span
                    className={`inline-flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br ${card.gradient} text-white shadow-sm`}
                  >
                    <card.icon size={20} />
                  </span>
                  <TrendingUp size={16} className="text-gray-300 dark:text-gray-600" />
                </div>

                <p className="text-3xl font-bold text-gray-900 dark:text-white">
                  {card.value?.toLocaleString() ?? 0}
                </p>
                <p className="mt-0.5 text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-gray-400">
                  {card.label}
                </p>
                <p className="mt-1 text-xs text-gray-400 dark:text-gray-500">{card.subtitle}</p>
              </div>
            ))}
          </div>
        )}

        {/* ── Chart + Pending Actions ── */}
        {!loading && (
          <div className="mb-6 grid grid-cols-1 gap-4 lg:grid-cols-3">
            {/* Chart – left 2 cols */}
            <div className="relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900 lg:col-span-2">
              <div className="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-amber-500 to-orange-500" />

              <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
                <div>
                  <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
                    Enrollment Trends
                  </h2>
                  <p className="text-sm text-gray-500 dark:text-gray-400">
                    Daily, weekly &amp; monthly enrollment data
                  </p>
                </div>
                <div className="inline-flex rounded-lg border border-gray-200 p-1 dark:border-gray-700">
                  {['daily', 'weekly', 'monthly'].map((mode) => (
                    <button
                      key={mode}
                      type="button"
                      onClick={() => setTrendMode(mode)}
                      className={`rounded-md px-3 py-1.5 text-sm font-medium capitalize transition ${
                        trendMode === mode
                          ? 'bg-amber-500 text-white shadow-sm'
                          : 'text-gray-600 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800'
                      }`}
                    >
                      {mode}
                    </button>
                  ))}
                </div>
              </div>

              {chartData.length === 0 ? (
                <div className="flex h-[320px] items-center justify-center text-sm text-gray-400 dark:text-gray-500">
                  No enrollment data available yet.
                </div>
              ) : (
                <EnrollmentAreaChart data={chartData} mode={trendMode} />
              )}
            </div>

            {/* Pending Actions – right 1 col */}
            <div className="relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900">
              <div className="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-amber-500 to-orange-500" />

              <div className="mb-4 flex items-center gap-2">
                <AlertCircle size={18} className="text-amber-500" />
                <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
                  Pending Actions
                </h2>
              </div>

              {!hasPendingActions ? (
                <div className="flex flex-col items-center justify-center py-10 text-center">
                  <ShieldCheck size={36} className="mb-2 text-emerald-400" />
                  <p className="text-sm font-medium text-gray-600 dark:text-gray-300">
                    All caught up!
                  </p>
                  <p className="text-xs text-gray-400 dark:text-gray-500">
                    No pending reviews right now.
                  </p>
                </div>
              ) : (
                <div className="space-y-3">
                  {/* Stables pending */}
                  <div className="flex items-center justify-between rounded-xl border border-gray-100 bg-gray-50 p-3.5 dark:border-gray-800 dark:bg-gray-800/50">
                    <div className="flex items-center gap-3">
                      <span className="inline-flex h-9 w-9 items-center justify-center rounded-lg bg-amber-100 text-amber-600 dark:bg-amber-900/40 dark:text-amber-400">
                        <Building2 size={18} />
                      </span>
                      <div>
                        <p className="text-sm font-medium text-gray-800 dark:text-gray-200">
                          Stables Pending
                        </p>
                        <p className="text-xs text-gray-400 dark:text-gray-500">
                          Awaiting approval
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2.5">
                      <span className="inline-flex min-w-[1.75rem] items-center justify-center rounded-full bg-amber-100 px-2 py-0.5 text-xs font-bold text-amber-700 dark:bg-amber-900/50 dark:text-amber-300">
                        {pendingStables}
                      </span>
                      <Link
                        to="/admin/stables"
                        className="inline-flex items-center gap-0.5 text-xs font-semibold text-amber-600 hover:text-amber-700 dark:text-amber-400 dark:hover:text-amber-300"
                      >
                        Review <ArrowUpRight size={13} />
                      </Link>
                    </div>
                  </div>

                  {/* Coaches unverified */}
                  <div className="flex items-center justify-between rounded-xl border border-gray-100 bg-gray-50 p-3.5 dark:border-gray-800 dark:bg-gray-800/50">
                    <div className="flex items-center gap-3">
                      <span className="inline-flex h-9 w-9 items-center justify-center rounded-lg bg-violet-100 text-violet-600 dark:bg-violet-900/40 dark:text-violet-400">
                        <GraduationCap size={18} />
                      </span>
                      <div>
                        <p className="text-sm font-medium text-gray-800 dark:text-gray-200">
                          Coaches Unverified
                        </p>
                        <p className="text-xs text-gray-400 dark:text-gray-500">
                          Awaiting verification
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2.5">
                      <span className="inline-flex min-w-[1.75rem] items-center justify-center rounded-full bg-violet-100 px-2 py-0.5 text-xs font-bold text-violet-700 dark:bg-violet-900/50 dark:text-violet-300">
                        {unverifiedCoaches}
                      </span>
                      <Link
                        to="/admin/coaches"
                        className="inline-flex items-center gap-0.5 text-xs font-semibold text-violet-600 hover:text-violet-700 dark:text-violet-400 dark:hover:text-violet-300"
                      >
                        Review <ArrowUpRight size={13} />
                      </Link>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* ── Three-column: Distribution / Activity / Quick Stats ── */}
        {!loading && (
          <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
            {/* Entity Distribution */}
            <div className="relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900">
              <div className="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-amber-500 to-orange-500" />
              <h2 className="mb-1 text-base font-semibold text-gray-900 dark:text-gray-100">
                Entity Distribution
              </h2>
              <p className="mb-3 text-xs text-gray-400 dark:text-gray-500">
                Stables, arenas, horses &amp; disciplines
              </p>

              <div className="mx-auto h-48 w-full max-w-[200px]">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={distributionData}
                      dataKey="value"
                      nameKey="name"
                      innerRadius={40}
                      outerRadius={72}
                      paddingAngle={3}
                      strokeWidth={0}
                    >
                      {distributionData.map((entry, i) => (
                        <Cell key={entry.name} fill={DISTRIBUTION_COLORS[i % DISTRIBUTION_COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>

              <div className="mt-3 grid grid-cols-2 gap-2">
                {distributionData.map((item, i) => (
                  <div key={item.name} className="flex items-center gap-2 text-xs text-gray-600 dark:text-gray-400">
                    <span
                      className="inline-block h-2.5 w-2.5 rounded-full"
                      style={{ backgroundColor: DISTRIBUTION_COLORS[i] }}
                    />
                    {item.name}: <span className="font-semibold text-gray-900 dark:text-gray-200">{item.value}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Recent Activity */}
            <div className="relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900">
              <div className="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-amber-500 to-orange-500" />
              <h2 className="mb-1 text-base font-semibold text-gray-900 dark:text-gray-100">
                Recent Activity
              </h2>
              <p className="mb-3 text-xs text-gray-400 dark:text-gray-500">
                Entity counts at a glance
              </p>

              <ul className="space-y-2.5">
                {recentActivity.map((item) => (
                  <li
                    key={item.label}
                    className="flex items-center justify-between rounded-lg border border-gray-100 bg-gray-50 px-3 py-2.5 dark:border-gray-800 dark:bg-gray-800/50"
                  >
                    <div className="flex items-center gap-2.5">
                      <item.icon size={16} className="text-amber-500" />
                      <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
                        {item.label}
                      </span>
                    </div>
                    <div className="text-right">
                      <span className="text-sm font-bold text-gray-900 dark:text-white">
                        {item.total}
                      </span>
                      <span className="ml-1.5 text-xs text-gray-400 dark:text-gray-500">
                        / {item.active} active
                      </span>
                    </div>
                  </li>
                ))}
              </ul>
            </div>

            {/* Quick Stats */}
            <div className="relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900">
              <div className="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-amber-500 to-orange-500" />
              <h2 className="mb-1 text-base font-semibold text-gray-900 dark:text-gray-100">
                Quick Stats
              </h2>
              <p className="mb-3 text-xs text-gray-400 dark:text-gray-500">
                Courses &amp; enrollments overview
              </p>

              <div className="space-y-4">
                {/* Courses */}
                <div className="flex items-center gap-4 rounded-xl border border-gray-100 bg-gray-50 p-3 dark:border-gray-800 dark:bg-gray-800/50">
                  <TotalActiveMiniChart
                    total={dashboard.stats.total_courses}
                    active={dashboard.stats.active_courses}
                  />
                  <div>
                    <div className="flex items-center gap-1.5">
                      <BookOpen size={14} className="text-emerald-500" />
                      <span className="text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-gray-400">
                        Courses
                      </span>
                    </div>
                    <p className="text-xl font-bold text-gray-900 dark:text-white">
                      {dashboard.stats.total_courses}
                    </p>
                    <p className="text-xs text-gray-400 dark:text-gray-500">
                      {dashboard.stats.active_courses} active
                    </p>
                  </div>
                </div>

                {/* Enrollments */}
                <div className="flex items-center gap-4 rounded-xl border border-gray-100 bg-gray-50 p-3 dark:border-gray-800 dark:bg-gray-800/50">
                  <TotalActiveMiniChart
                    total={dashboard.stats.total_enrollments}
                    active={dashboard.stats.active_enrollments}
                  />
                  <div>
                    <div className="flex items-center gap-1.5">
                      <ClipboardList size={14} className="text-blue-500" />
                      <span className="text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-gray-400">
                        Enrollments
                      </span>
                    </div>
                    <p className="text-xl font-bold text-gray-900 dark:text-white">
                      {dashboard.stats.total_enrollments}
                    </p>
                    <p className="text-xs text-gray-400 dark:text-gray-500">
                      {dashboard.stats.active_enrollments} active
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default AdminDashboardPage;
