// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const projects = [
  {
    id: 1,
    name: 'Logo redesign',
    description: 'New logo and digital asset playbook.',
    hours: '20.0',
    rate: '$100.00',
    price: '$2,000.00',
  },
  {
    id: 2,
    name: 'Website redesign',
    description: 'Design and program new company website.',
    hours: '52.0',
    rate: '$100.00',
    price: '$5,200.00',
  },
  {
    id: 3,
    name: 'Business cards',
    description: 'Design and production of 3.5" x 2.0" business cards.',
    hours: '12.0',
    rate: '$100.00',
    price: '$1,200.00',
  },
  {
    id: 4,
    name: 'T-shirt design',
    description: 'Three t-shirt design concepts.',
    hours: '4.0',
    rate: '$100.00',
    price: '$400.00',
  },
]

export function WithSummaryRows15() {
  return (
    <div className="px-4 sm:px-6 lg:px-8">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-base font-semibold text-gray-900 dark:text-white">Invoice</h1>
          <p className="mt-2 text-sm text-gray-700 dark:text-gray-300">
            For work completed from <time dateTime="2022-08-01">August 1, 2022</time> to{' '}
            <time dateTime="2022-08-31">August 31, 2022</time>.
          </p>
        </div>
        <div className="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
          <button
            type="button"
            className="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:hover:bg-indigo-400 dark:focus-visible:outline-indigo-500"
          >
            Print
          </button>
        </div>
      </div>
      <div className="-mx-4 mt-8 flow-root sm:mx-0">
        <table className="min-w-full">
          <colgroup>
            <col className="w-full sm:w-1/2" />
            <col className="sm:w-1/6" />
            <col className="sm:w-1/6" />
            <col className="sm:w-1/6" />
          </colgroup>
          <thead className="border-b border-gray-300 text-gray-900 dark:border-white/15 dark:text-white">
            <tr>
              <th
                scope="col"
                className="py-3.5 pr-3 pl-4 text-left text-sm font-semibold text-gray-900 sm:pl-0 dark:text-white"
              >
                Project
              </th>
              <th
                scope="col"
                className="hidden px-3 py-3.5 text-right text-sm font-semibold text-gray-900 sm:table-cell dark:text-white"
              >
                Hours
              </th>
              <th
                scope="col"
                className="hidden px-3 py-3.5 text-right text-sm font-semibold text-gray-900 sm:table-cell dark:text-white"
              >
                Rate
              </th>
              <th
                scope="col"
                className="py-3.5 pr-4 pl-3 text-right text-sm font-semibold text-gray-900 sm:pr-0 dark:text-white"
              >
                Price
              </th>
            </tr>
          </thead>
          <tbody>
            {projects.map((project) => (
              <tr key={project.id} className="border-b border-gray-200 dark:border-white/10">
                <td className="max-w-0 py-5 pr-3 pl-4 text-sm sm:pl-0">
                  <div className="font-medium text-gray-900 dark:text-white">{project.name}</div>
                  <div className="mt-1 truncate text-gray-500 dark:text-gray-400">{project.description}</div>
                </td>
                <td className="hidden px-3 py-5 text-right text-sm text-gray-500 sm:table-cell dark:text-gray-400">
                  {project.hours}
                </td>
                <td className="hidden px-3 py-5 text-right text-sm text-gray-500 sm:table-cell dark:text-gray-400">
                  {project.rate}
                </td>
                <td className="py-5 pr-4 pl-3 text-right text-sm text-gray-500 sm:pr-0 dark:text-gray-400">
                  {project.price}
                </td>
              </tr>
            ))}
          </tbody>
          <tfoot>
            <tr>
              <th
                scope="row"
                colSpan={3}
                className="hidden pt-6 pr-3 pl-4 text-right text-sm font-normal text-gray-500 sm:table-cell sm:pl-0 dark:text-gray-400"
              >
                Subtotal
              </th>
              <th
                scope="row"
                className="pt-6 pr-3 pl-4 text-left text-sm font-normal text-gray-500 sm:hidden dark:text-gray-400"
              >
                Subtotal
              </th>
              <td className="pt-6 pr-4 pl-3 text-right text-sm text-gray-500 sm:pr-0 dark:text-gray-400">$8,800.00</td>
            </tr>
            <tr>
              <th
                scope="row"
                colSpan={3}
                className="hidden pt-4 pr-3 pl-4 text-right text-sm font-normal text-gray-500 sm:table-cell sm:pl-0 dark:text-gray-400"
              >
                Tax
              </th>
              <th
                scope="row"
                className="pt-4 pr-3 pl-4 text-left text-sm font-normal text-gray-500 sm:hidden dark:text-gray-400"
              >
                Tax
              </th>
              <td className="pt-4 pr-4 pl-3 text-right text-sm text-gray-500 sm:pr-0 dark:text-gray-400">$1,760.00</td>
            </tr>
            <tr>
              <th
                scope="row"
                colSpan={3}
                className="hidden pt-4 pr-3 pl-4 text-right text-sm font-semibold text-gray-900 sm:table-cell sm:pl-0 dark:text-white"
              >
                Total
              </th>
              <th
                scope="row"
                className="pt-4 pr-3 pl-4 text-left text-sm font-semibold text-gray-900 sm:hidden dark:text-white"
              >
                Total
              </th>
              <td className="pt-4 pr-4 pl-3 text-right text-sm font-semibold text-gray-900 sm:pr-0 dark:text-white">
                $10,560.00
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  )
}
