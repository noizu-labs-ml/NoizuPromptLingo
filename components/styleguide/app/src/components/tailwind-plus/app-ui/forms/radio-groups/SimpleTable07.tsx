// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const plans = [
  { id: 'startup', name: 'Startup', priceMonthly: '$29', priceYearly: '$290', limit: 'Up to 5 active job postings' },
  { id: 'business', name: 'Business', priceMonthly: '$99', priceYearly: '$990', limit: 'Up to 25 active job postings' },
  {
    id: 'enterprise',
    name: 'Enterprise',
    priceMonthly: '$249',
    priceYearly: '$2490',
    limit: 'Unlimited active job postings',
  },
]

export function SimpleTable07() {
  return (
    <fieldset aria-label="Pricing plans" className="relative -space-y-px rounded-md bg-white dark:bg-gray-800/50">
      {plans.map((plan) => (
        <label
          key={plan.id}
          aria-label={plan.name}
          aria-description={`${plan.priceMonthly} per month, ${plan.priceYearly} per year, ${plan.limit}`}
          className="group flex flex-col border border-gray-200 p-4 first:rounded-tl-md first:rounded-tr-md last:rounded-br-md last:rounded-bl-md focus:outline-hidden has-checked:relative has-checked:border-indigo-200 has-checked:bg-indigo-50 md:grid md:grid-cols-3 md:pr-6 md:pl-4 dark:border-gray-700 dark:has-checked:border-indigo-800 dark:has-checked:bg-indigo-600/10"
        >
          <span className="flex items-center gap-3 text-sm">
            <input
              defaultValue={plan.id}
              defaultChecked={plan.id === 'startup'}
              name="pricing-plan"
              type="radio"
              className="relative size-4 appearance-none rounded-full border border-gray-300 bg-white before:absolute before:inset-1 before:rounded-full before:bg-white not-checked:before:hidden checked:border-indigo-600 checked:bg-indigo-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:border-gray-300 disabled:bg-gray-100 disabled:before:bg-gray-400 dark:border-white/10 dark:bg-white/5 dark:checked:border-indigo-500 dark:checked:bg-indigo-500 dark:focus-visible:outline-indigo-500 dark:disabled:border-white/5 dark:disabled:bg-white/10 dark:disabled:before:bg-white/20 forced-colors:appearance-auto forced-colors:before:hidden"
            />
            <span className="font-medium text-gray-900 group-has-checked:text-indigo-900 dark:text-white dark:group-has-checked:text-indigo-300">
              {plan.name}
            </span>
          </span>
          <span className="ml-6 pl-1 text-sm md:ml-0 md:pl-0 md:text-center">
            <span className="font-medium text-gray-900 group-has-checked:text-indigo-900 dark:text-white dark:group-has-checked:text-indigo-300">
              {plan.priceMonthly} / mo
            </span>{' '}
            <span className="text-gray-500 group-has-checked:text-indigo-700 dark:text-gray-400 dark:group-has-checked:text-indigo-300/75">
              ({plan.priceYearly} / yr)
            </span>
          </span>
          <span className="ml-6 pl-1 text-sm text-gray-500 group-has-checked:text-indigo-700 md:ml-0 md:pl-0 md:text-right dark:text-gray-400 dark:group-has-checked:text-indigo-300/75">
            {plan.limit}
          </span>
        </label>
      ))}
    </fieldset>
  )
}
