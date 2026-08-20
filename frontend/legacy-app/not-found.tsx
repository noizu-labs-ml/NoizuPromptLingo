import Link from "next/link";
import { ExclamationTriangleIcon } from "@heroicons/react/24/outline";
import { EmptyState } from "@/components/primitives/EmptyState";

export default function NotFound() {
  return (
    <div className="flex items-center justify-center min-h-[60vh]">
      <EmptyState
        icon={<ExclamationTriangleIcon />}
        title="Page not found"
        description="The path you requested isn't in the dashboard."
        action={
          <Link
            href="/"
            className="inline-flex items-center rounded-md bg-accent/10 px-4 py-2 text-sm font-medium text-accent hover:bg-accent/20 transition-colors"
          >
            Back to overview
          </Link>
        }
      />
    </div>
  );
}
