'use client';

import { StarIcon } from '@heroicons/react/24/outline';
import { StarIcon as StarIconSolid } from '@heroicons/react/24/solid';
import { useStarredProjects } from '@/context/starred';

export function StarToggle({ projectId }: { projectId: string }) {
  const { isStarred, toggle } = useStarredProjects();
  const starred = isStarred(projectId);
  return (
    <button
      type="button"
      className={`star-toggle${starred ? ' is-starred' : ''}`}
      aria-pressed={starred}
      aria-label={starred ? 'Remove star' : 'Star project'}
      title={starred ? 'Remove star' : 'Star project'}
      onClick={(e) => {
        // Keep the row's primary action (open/select) from firing.
        e.stopPropagation();
        e.preventDefault();
        toggle(projectId);
      }}
    >
      {starred ? <StarIconSolid aria-hidden="true" /> : <StarIcon aria-hidden="true" />}
    </button>
  );
}
