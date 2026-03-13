import { useState } from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { AnimatePresence, motion } from 'framer-motion';
import {
  LayoutDashboard,
  CalendarCheck,
  Building2,
  CircleDot,
  Footprints,
  Zap,
  GraduationCap,
  BookOpen,
  Users,
  CreditCard,
  Wallet,
  BarChart3,
  Settings,
  Bell,
  Menu,
  X,
  LogOut,
  ChevronRight,
} from 'lucide-react';
import ThemeToggle from '../theme/ThemeToggle';
import { logoutAdmin } from '../../features/auth/authSlice';

const navSections = [
  {
    label: 'Main',
    items: [
      { label: 'Dashboard', to: '/admin/dashboard', icon: LayoutDashboard },
      { label: 'Bookings', to: '/admin/bookings', icon: CalendarCheck },
    ],
  },
  {
    label: 'Management',
    items: [
      { label: 'Stables', to: '/admin/stables', icon: Building2 },
      { label: 'Arenas', to: '/admin/arenas', icon: CircleDot },
      { label: 'Horses', to: '/admin/horses', icon: Footprints },
      { label: 'Disciplines', to: '/admin/disciplines', icon: Zap },
    ],
  },
  {
    label: 'People',
    items: [
      { label: 'Coaches', to: '/admin/coaches', icon: GraduationCap },
      { label: 'Riders', to: '/admin/riders', icon: Users },
    ],
  },
  {
    label: 'Learning',
    items: [
      { label: 'Courses', to: '/admin/courses', icon: BookOpen },
    ],
  },
  {
    label: 'Finance',
    items: [
      { label: 'Payments', to: '/admin/payments', icon: CreditCard },
      { label: 'Payouts', to: '/admin/payouts', icon: Wallet },
    ],
  },
  {
    label: 'System',
    items: [
      { label: 'Analytics', to: '/admin/analytics', icon: BarChart3 },
      { label: 'Settings', to: '/admin/settings', icon: Settings },
      { label: 'Notifications', to: '/admin/notifications', icon: Bell },
    ],
  },
];

const SidebarContent = ({ onNavigate }) => (
  <div className="flex h-full flex-col">
    <div className="flex items-center gap-3 px-3 pb-6 pt-2">
      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-amber-500 shadow-md shadow-amber-200 dark:shadow-amber-900/40">
        <Footprints size={18} strokeWidth={2} className="text-white" />
      </div>
      <div>
        <p className="text-[10px] font-semibold uppercase tracking-widest text-amber-500">
          Horse Riding
        </p>
        <h2 className="text-sm font-bold leading-tight text-gray-900 dark:text-gray-100">
          Admin Panel
        </h2>
      </div>
    </div>

    <nav className="flex-1 space-y-4 overflow-y-auto">
      {navSections.map((section) => (
        <div key={section.label}>
          <p className="mb-1.5 px-3 text-[10px] font-semibold uppercase tracking-widest text-gray-400 dark:text-gray-500">
            {section.label}
          </p>
          <div className="space-y-0.5">
            {section.items.map(({ label, to, icon: NavIcon }) => (
              <NavLink
                key={to}
                to={to}
                onClick={onNavigate}
                className={({ isActive }) =>
                  `group flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all duration-150 ${
                    isActive
                      ? 'bg-amber-50 text-amber-700 dark:bg-amber-900/25 dark:text-amber-400'
                      : 'text-gray-500 hover:bg-gray-100 hover:text-gray-900 dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-gray-100'
                  }`
                }
              >
                {({ isActive }) => (
                  <>
                    <span
                      className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-lg transition-all duration-150 ${
                        isActive
                          ? 'bg-amber-100 text-amber-600 dark:bg-amber-900/40 dark:text-amber-400'
                          : 'bg-gray-100 text-gray-400 group-hover:bg-gray-200 group-hover:text-gray-600 dark:bg-gray-800 dark:text-gray-500 dark:group-hover:bg-gray-700 dark:group-hover:text-gray-300'
                      }`}
                    >
                      <NavIcon size={15} strokeWidth={isActive ? 2.2 : 1.8} />
                    </span>
                    <span className="flex-1">{label}</span>
                    {isActive && (
                      <ChevronRight size={14} strokeWidth={2.5} className="text-amber-400 dark:text-amber-500" />
                    )}
                  </>
                )}
              </NavLink>
            ))}
          </div>
        </div>
      ))}
    </nav>
  </div>
);

const AdminAppLayout = () => {
  const dispatch = useDispatch();
  const { admin } = useSelector((state) => state.auth);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const initials = `${admin?.first_name?.[0] || 'A'}${admin?.last_name?.[0] || ''}`.toUpperCase();
  const fullName = [admin?.first_name, admin?.last_name].filter(Boolean).join(' ') || 'Admin';

  return (
    <div className="h-screen overflow-hidden bg-gray-100 dark:bg-gray-950 lg:grid lg:grid-cols-[260px_1fr]">

      <aside className="hidden h-full overflow-y-auto border-r border-gray-200 bg-white p-4 dark:border-gray-800 dark:bg-gray-900 lg:block">
        <SidebarContent />
      </aside>

      <AnimatePresence>
        {mobileMenuOpen && (
          <>
            <motion.div
              className="fixed inset-0 z-30 bg-gray-900/50 backdrop-blur-sm lg:hidden"
              onClick={() => setMobileMenuOpen(false)}
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.2 }}
            />
            <motion.aside
              className="fixed bottom-0 left-0 top-0 z-40 w-[78vw] max-w-[280px] overflow-y-auto border-r border-gray-200 bg-white p-4 shadow-2xl dark:border-gray-800 dark:bg-gray-900 lg:hidden"
              initial={{ x: -300 }}
              animate={{ x: 0 }}
              exit={{ x: -300 }}
              transition={{ type: 'spring', stiffness: 300, damping: 30 }}
            >
              <button
                type="button"
                aria-label="Close menu"
                onClick={() => setMobileMenuOpen(false)}
                className="mb-4 flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-100 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-800"
              >
                <X size={16} />
              </button>
              <SidebarContent onNavigate={() => setMobileMenuOpen(false)} />
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      <div className="flex h-full flex-col gap-3 overflow-hidden p-3 sm:p-4">

        <header className="flex shrink-0 flex-wrap items-center justify-between gap-3 rounded-2xl border border-gray-200 bg-white px-4 py-3 shadow-sm dark:border-gray-800 dark:bg-gray-900">

          <div className="flex items-center gap-3">
            <button
              type="button"
              aria-label="Open menu"
              onClick={() => setMobileMenuOpen(true)}
              className="inline-flex h-9 w-9 items-center justify-center rounded-xl border border-gray-200 text-gray-600 transition hover:bg-gray-100 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800 lg:hidden"
            >
              <Menu size={17} />
            </button>

            <div>
              <h1 className="text-sm font-bold text-gray-900 dark:text-gray-100 sm:text-base">
                Equestrian Admin
              </h1>
              <p className="hidden text-xs text-gray-500 dark:text-gray-400 sm:block">
                Manage stables, horses, arenas &amp; disciplines
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <ThemeToggle />

            <div className="flex items-center gap-2 rounded-full border border-gray-200 bg-gray-50 py-1 pl-1 pr-3 dark:border-gray-700 dark:bg-gray-800">
              <div className="grid h-7 w-7 shrink-0 place-items-center rounded-full bg-gradient-to-br from-amber-400 to-orange-500 text-[11px] font-bold text-white shadow-sm">
                {initials}
              </div>
              <div className="hidden md:block">
                <strong className="block text-xs font-semibold text-gray-900 dark:text-gray-100">
                  {fullName}
                </strong>
                <span className="block max-w-[140px] truncate text-[10px] text-gray-400 dark:text-gray-500">
                  {admin?.email}
                </span>
              </div>
            </div>

            <button
              type="button"
              onClick={() => dispatch(logoutAdmin())}
              aria-label="Logout"
              className="flex h-9 w-9 items-center justify-center rounded-xl border border-gray-200 text-gray-500 transition hover:border-red-200 hover:bg-red-50 hover:text-red-600 dark:border-gray-700 dark:text-gray-400 dark:hover:border-red-800 dark:hover:bg-red-900/20 dark:hover:text-red-400 sm:w-auto sm:gap-1.5 sm:px-3"
            >
              <LogOut size={15} strokeWidth={2} />
              <span className="hidden text-xs font-medium sm:inline">Logout</span>
            </button>
          </div>
        </header>

        <main className="flex-1 overflow-y-auto rounded-2xl border border-gray-200 bg-white p-4 shadow-sm dark:border-gray-800 dark:bg-gray-900 sm:p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default AdminAppLayout;
