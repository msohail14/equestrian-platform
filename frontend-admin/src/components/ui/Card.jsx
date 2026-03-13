const Card = ({ title, subtitle, accent, actions, className = '', children }) => (
  <section className={`relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900 ${className}`}>
    {accent && <div className={`absolute inset-x-0 top-0 h-1 bg-gradient-to-r ${accent}`} />}
    {(title || actions) && (
      <div className="mb-4 flex items-center justify-between">
        <div>
          {title && <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">{title}</h2>}
          {subtitle && <p className="text-sm text-gray-500 dark:text-gray-400">{subtitle}</p>}
        </div>
        {actions && <div className="flex items-center gap-2">{actions}</div>}
      </div>
    )}
    {children}
  </section>
);

export default Card;
