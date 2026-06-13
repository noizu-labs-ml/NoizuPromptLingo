// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function BasicResponsive06() {
  return (
    <div className="sm:flex">
      <div className="mb-4 shrink-0 sm:mr-4 sm:mb-0">
        <svg
          fill="none"
          stroke="currentColor"
          viewBox="0 0 200 200"
          preserveAspectRatio="none"
          aria-hidden="true"
          className="size-16 border border-gray-300 bg-white text-gray-300 dark:border-white/15 dark:bg-gray-900 dark:text-white/15"
        >
          <path d="M0 0l200 200M0 200L200 0" strokeWidth={1} vectorEffect="non-scaling-stroke" />
        </svg>
      </div>
      <div>
        <h4 className="text-lg font-bold text-gray-900 dark:text-white">Lorem ipsum</h4>
        <p className="mt-1 text-gray-500 dark:text-gray-400">
          Repudiandae sint consequuntur vel. Amet ut nobis explicabo numquam expedita quia omnis voluptatem. Minus
          quidem ipsam quia iusto.
        </p>
      </div>
    </div>
  )
}
