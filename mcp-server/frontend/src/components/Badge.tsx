interface BadgeProps {
  label: string;
  color?: string;
  size?: 'sm' | 'md';
}

export function Badge({ label, color = 'bg-gray-100 text-gray-800', size = 'sm' }: BadgeProps) {
  const sizeClasses = size === 'sm' ? 'px-2 py-0.5 text-xs' : 'px-2.5 py-1 text-sm';
  return (
    <span className={`inline-flex items-center rounded-full font-medium ${color} ${sizeClasses}`}>
      {label}
    </span>
  );
}

export function StatusBadge({ status }: { status: string }) {
  const colors: Record<string, string> = {
    pending: 'bg-gray-100 text-gray-800',
    in_progress: 'bg-blue-100 text-blue-800',
    blocked: 'bg-red-100 text-red-800',
    review: 'bg-purple-100 text-purple-800',
    done: 'bg-green-100 text-green-800',
    active: 'bg-green-100 text-green-800',
    archived: 'bg-gray-100 text-gray-800',
  };

  const labels: Record<string, string> = {
    pending: 'Pending',
    in_progress: 'In Progress',
    blocked: 'Blocked',
    review: 'Review',
    done: 'Done',
    active: 'Active',
    archived: 'Archived',
  };

  return <Badge label={labels[status] || status} color={colors[status]} />;
}

export function PriorityBadge({ priority }: { priority: number }) {
  const colors: Record<number, string> = {
    0: 'bg-gray-100 text-gray-800',
    1: 'bg-blue-100 text-blue-800',
    2: 'bg-yellow-100 text-yellow-800',
    3: 'bg-red-100 text-red-800',
  };

  const labels: Record<number, string> = {
    0: 'Low',
    1: 'Normal',
    2: 'High',
    3: 'Urgent',
  };

  return <Badge label={labels[priority] || `P${priority}`} color={colors[priority]} />;
}

export function ComplexityBadge({ complexity }: { complexity: number }) {
  const colors: Record<number, string> = {
    1: 'bg-green-100 text-green-800',
    2: 'bg-blue-100 text-blue-800',
    3: 'bg-yellow-100 text-yellow-800',
    4: 'bg-orange-100 text-orange-800',
    5: 'bg-red-100 text-red-800',
  };

  const labels: Record<number, string> = {
    1: 'Trivial',
    2: 'Simple',
    3: 'Moderate',
    4: 'Complex',
    5: 'V. Complex',
  };

  return <Badge label={labels[complexity] || `C${complexity}`} color={colors[complexity]} />;
}
