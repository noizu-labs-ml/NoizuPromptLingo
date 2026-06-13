// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const accounts = [
  { id: 'checking', name: 'Checking', description: 'CIBC ••••6610' },
  { id: 'savings', name: 'Savings', description: 'Bank of America ••••0149' },
  { id: 'mastercard', name: 'Mastercard', description: 'Capital One ••••7877' },
]

export function ListWithRadioOnRight05() {
  return (
    <fieldset>
      <legend className="text-sm/6 font-semibold text-gray-900 dark:text-white">Transfer funds</legend>
      <p className="mt-1 text-sm/6 text-gray-600 dark:text-gray-400">Transfer your balance to your bank account.</p>
      <div className="mt-2.5 divide-y divide-gray-200 dark:divide-white/10">
        {accounts.map((account, accountIdx) => (
          <div key={accountIdx} className="relative flex items-start pt-3.5 pb-4">
            <div className="min-w-0 flex-1 text-sm/6">
              <label htmlFor={`account-${account.id}`} className="font-medium text-gray-900 dark:text-white">
                {account.name}
              </label>
              <p id={`account-${account.id}-description`} className="text-gray-500 dark:text-gray-400">
                {account.description}
              </p>
            </div>
            <div className="ml-3 flex h-6 items-center">
              <input
                defaultChecked={account.id === 'checking'}
                id={`account-${account.id}`}
                name="account"
                type="radio"
                aria-describedby={`account-${account.id}-description`}
                className="relative size-4 appearance-none rounded-full border border-gray-300 bg-white before:absolute before:inset-1 before:rounded-full before:bg-white not-checked:before:hidden checked:border-indigo-600 checked:bg-indigo-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:border-gray-300 disabled:bg-gray-100 disabled:before:bg-gray-400 dark:border-white/10 dark:bg-white/5 dark:checked:border-indigo-500 dark:checked:bg-indigo-500 dark:focus-visible:outline-indigo-500 dark:disabled:border-white/5 dark:disabled:bg-white/10 dark:disabled:before:bg-white/20 forced-colors:appearance-auto forced-colors:before:hidden"
              />
            </div>
          </div>
        ))}
      </div>
    </fieldset>
  )
}
