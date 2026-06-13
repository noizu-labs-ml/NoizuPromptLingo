// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function WithWell08() {
  return (
    <div className="bg-white shadow-sm sm:rounded-lg dark:bg-gray-800/50 dark:shadow-none dark:outline dark:-outline-offset-1 dark:outline-white/10">
      <div className="px-4 py-5 sm:p-6">
        <h3 className="text-base font-semibold text-gray-900 dark:text-white">Payment method</h3>
        <div className="mt-5">
          <div className="rounded-md bg-gray-50 px-6 py-5 sm:flex sm:items-start sm:justify-between dark:bg-gray-800">
            <h4 className="sr-only">Visa</h4>
            <div className="sm:flex sm:items-start">
              <svg viewBox="0 0 36 24" aria-hidden="true" className="h-8 w-auto sm:h-6 sm:shrink-0">
                <rect rx={4} fill="#224DBA" width={36} height={24} />
                <path
                  d="M10.925 15.673H8.874l-1.538-6c-.073-.276-.228-.52-.456-.635A6.575 6.575 0 005 8.403v-.231h3.304c.456 0 .798.347.855.75l.798 4.328 2.05-5.078h1.994l-3.076 7.5zm4.216 0h-1.937L14.8 8.172h1.937l-1.595 7.5zm4.101-5.422c.057-.404.399-.635.798-.635a3.54 3.54 0 011.88.346l.342-1.615A4.808 4.808 0 0020.496 8c-1.88 0-3.248 1.039-3.248 2.481 0 1.097.969 1.673 1.653 2.02.74.346 1.025.577.968.923 0 .519-.57.75-1.139.75a4.795 4.795 0 01-1.994-.462l-.342 1.616a5.48 5.48 0 002.108.404c2.108.057 3.418-.981 3.418-2.539 0-1.962-2.678-2.077-2.678-2.942zm9.457 5.422L27.16 8.172h-1.652a.858.858 0 00-.798.577l-2.848 6.924h1.994l.398-1.096h2.45l.228 1.096h1.766zm-2.905-5.482l.57 2.827h-1.596l1.026-2.827z"
                  fill="#fff"
                />
              </svg>
              <div className="mt-3 sm:mt-0 sm:ml-4">
                <div className="text-sm font-medium text-gray-900 dark:text-white">Ending with 4242</div>
                <div className="mt-1 text-sm text-gray-600 sm:flex sm:items-center dark:text-gray-400">
                  <div>Expires 12/20</div>
                  <span aria-hidden="true" className="hidden sm:mx-2 sm:inline">
                    &middot;
                  </span>
                  <div className="mt-1 sm:mt-0">Last updated on 22 Aug 2017</div>
                </div>
              </div>
            </div>
            <div className="mt-4 sm:mt-0 sm:ml-6 sm:shrink-0">
              <button
                type="button"
                className="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-xs ring-1 ring-gray-300 ring-inset hover:bg-gray-50 dark:bg-white/10 dark:text-white dark:shadow-none dark:ring-white/5 dark:hover:bg-white/20"
              >
                Edit
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
