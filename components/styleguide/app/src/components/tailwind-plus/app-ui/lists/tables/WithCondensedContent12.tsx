// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const transactions = [
  {
    id: 'AAPS0L',
    company: 'Chase & Co.',
    share: 'CAC',
    commission: '+$4.37',
    price: '$3,509.00',
    quantity: '12.00',
    netAmount: '$4,397.00',
  },
  {
    id: 'O2KMND',
    company: 'Amazon.com Inc.',
    share: 'AMZN',
    commission: '+$5.92',
    price: '$2,900.00',
    quantity: '8.80',
    netAmount: '$3,509.00',
  },
  {
    id: '1LP2P4',
    company: 'Procter & Gamble',
    share: 'PG',
    commission: '-$5.65',
    price: '$7,978.00',
    quantity: '2.30',
    netAmount: '$2,652.00',
  },
  {
    id: 'PS9FJGL',
    company: 'Berkshire Hathaway',
    share: 'BRK',
    commission: '+$4.37',
    price: '$3,116.00',
    quantity: '48.00',
    netAmount: '$6,055.00',
  },
  {
    id: 'QYR135',
    company: 'Apple Inc.',
    share: 'AAPL',
    commission: '+$38.00',
    price: '$8,508.00',
    quantity: '36.00',
    netAmount: '$3,496.00',
  },
  {
    id: '99SLSM',
    company: 'NVIDIA Corporation',
    share: 'NVDA',
    commission: '+$1,427.00',
    price: '$4,425.00',
    quantity: '18.00',
    netAmount: '$2,109.00',
  },
  {
    id: 'OSDJLS',
    company: 'Johnson & Johnson',
    share: 'JNJ',
    commission: '+$1,937.23',
    price: '$4,038.00',
    quantity: '32.00',
    netAmount: '$7,210.00',
  },
  {
    id: '4HJK3N',
    company: 'JPMorgan',
    share: 'JPM',
    commission: '-$3.67',
    price: '$3,966.00',
    quantity: '80.00',
    netAmount: '$6,432.00',
  },
]

export function WithCondensedContent12() {
  return (
    <div className="px-4 sm:px-6 lg:px-8">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-base font-semibold text-gray-900 dark:text-white">Transactions</h1>
          <p className="mt-2 text-sm text-gray-700 dark:text-gray-300">
            A table of placeholder stock market data that does not make any sense.
          </p>
        </div>
        <div className="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
          <button
            type="button"
            className="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:hover:bg-indigo-400 dark:focus-visible:outline-indigo-500"
          >
            Export
          </button>
        </div>
      </div>
      <div className="mt-8 flow-root">
        <div className="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div className="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
            <table className="relative min-w-full divide-y divide-gray-300 dark:divide-white/15">
              <thead>
                <tr>
                  <th
                    scope="col"
                    className="py-3.5 pr-3 pl-4 text-left text-sm font-semibold whitespace-nowrap text-gray-900 sm:pl-0 dark:text-white"
                  >
                    Transaction ID
                  </th>
                  <th
                    scope="col"
                    className="px-2 py-3.5 text-left text-sm font-semibold whitespace-nowrap text-gray-900 dark:text-white"
                  >
                    Company
                  </th>
                  <th
                    scope="col"
                    className="px-2 py-3.5 text-left text-sm font-semibold whitespace-nowrap text-gray-900 dark:text-white"
                  >
                    Share
                  </th>
                  <th
                    scope="col"
                    className="px-2 py-3.5 text-left text-sm font-semibold whitespace-nowrap text-gray-900 dark:text-white"
                  >
                    Commision
                  </th>
                  <th
                    scope="col"
                    className="px-2 py-3.5 text-left text-sm font-semibold whitespace-nowrap text-gray-900 dark:text-white"
                  >
                    Price
                  </th>
                  <th
                    scope="col"
                    className="px-2 py-3.5 text-left text-sm font-semibold whitespace-nowrap text-gray-900 dark:text-white"
                  >
                    Quantity
                  </th>
                  <th
                    scope="col"
                    className="px-2 py-3.5 text-left text-sm font-semibold whitespace-nowrap text-gray-900 dark:text-white"
                  >
                    Net amount
                  </th>
                  <th scope="col" className="py-3.5 pr-4 pl-3 whitespace-nowrap sm:pr-0">
                    <span className="sr-only">Edit</span>
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 bg-white dark:divide-white/10 dark:bg-gray-900">
                {transactions.map((transaction) => (
                  <tr key={transaction.id}>
                    <td className="py-2 pr-3 pl-4 text-sm whitespace-nowrap text-gray-500 sm:pl-0 dark:text-gray-400">
                      {transaction.id}
                    </td>
                    <td className="px-2 py-2 text-sm font-medium whitespace-nowrap text-gray-900 dark:text-white">
                      {transaction.company}
                    </td>
                    <td className="px-2 py-2 text-sm whitespace-nowrap text-gray-900 dark:text-white">
                      {transaction.share}
                    </td>
                    <td className="px-2 py-2 text-sm whitespace-nowrap text-gray-500 dark:text-gray-400">
                      {transaction.commission}
                    </td>
                    <td className="px-2 py-2 text-sm whitespace-nowrap text-gray-500 dark:text-gray-400">
                      {transaction.price}
                    </td>
                    <td className="px-2 py-2 text-sm whitespace-nowrap text-gray-500 dark:text-gray-400">
                      {transaction.quantity}
                    </td>
                    <td className="px-2 py-2 text-sm whitespace-nowrap text-gray-500 dark:text-gray-400">
                      {transaction.netAmount}
                    </td>
                    <td className="py-2 pr-4 pl-3 text-right text-sm font-medium whitespace-nowrap sm:pr-0">
                      <a
                        href="#"
                        className="text-indigo-600 hover:text-indigo-900 dark:text-indigo-400 dark:hover:text-indigo-300"
                      >
                        Edit<span className="sr-only">, {transaction.id}</span>
                      </a>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
