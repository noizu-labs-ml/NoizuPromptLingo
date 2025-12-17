'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Plus, RefreshCw, ChevronRight } from 'lucide-react';
import { TaskQueue, listTaskQueues, createTaskQueue } from '@/lib/api';
import { StatusBadge } from '@/components/Badge';
import { Button } from '@/components/Button';
import { Input, Textarea } from '@/components/Input';

export default function TaskQueuesPage() {
  const [queues, setQueues] = useState<TaskQueue[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({ name: '', description: '' });
  const [submitting, setSubmitting] = useState(false);

  const fetchQueues = async () => {
    try {
      setLoading(true);
      const data = await listTaskQueues();
      setQueues(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load queues');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchQueues();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim()) return;

    try {
      setSubmitting(true);
      await createTaskQueue({
        name: formData.name.trim(),
        description: formData.description.trim() || undefined,
      });
      setFormData({ name: '', description: '' });
      setShowForm(false);
      fetchQueues();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create queue');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Task Queues</h1>
          <p className="text-gray-600">Manage work items and track progress</p>
        </div>
        <div className="flex space-x-2">
          <Button variant="ghost" onClick={fetchQueues} disabled={loading}>
            <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
          <Button onClick={() => setShowForm(!showForm)}>
            <Plus className="h-4 w-4 mr-2" />
            New Queue
          </Button>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      {showForm && (
        <div className="bg-white rounded-lg shadow-sm border p-6">
          <h2 className="text-lg font-semibold mb-4">Create Task Queue</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              label="Name"
              placeholder="Queue name"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              required
            />
            <Textarea
              label="Description"
              placeholder="Optional description"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            />
            <div className="flex space-x-2">
              <Button type="submit" disabled={submitting || !formData.name.trim()}>
                {submitting ? 'Creating...' : 'Create Queue'}
              </Button>
              <Button type="button" variant="secondary" onClick={() => setShowForm(false)}>
                Cancel
              </Button>
            </div>
          </form>
        </div>
      )}

      {loading && !queues.length ? (
        <div className="text-center py-12">
          <RefreshCw className="h-8 w-8 animate-spin mx-auto text-gray-400" />
          <p className="mt-2 text-gray-500">Loading queues...</p>
        </div>
      ) : queues.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-lg border">
          <p className="text-gray-500">No task queues yet</p>
          <Button className="mt-4" onClick={() => setShowForm(true)}>
            <Plus className="h-4 w-4 mr-2" />
            Create your first queue
          </Button>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Queue
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tasks
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Created
                </th>
                <th className="relative px-6 py-3">
                  <span className="sr-only">View</span>
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {queues.map((queue) => (
                <tr key={queue.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">{queue.name}</div>
                      {queue.description && (
                        <div className="text-sm text-gray-500 truncate max-w-xs">
                          {queue.description}
                        </div>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <StatusBadge status={queue.status} />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {queue.task_count ?? '-'}
                    {queue.pending_count !== undefined && (
                      <span className="text-yellow-600 ml-1">
                        ({queue.pending_count} pending)
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(queue.created_at).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <Link
                      href={`/tasks/${queue.id}`}
                      className="text-blue-600 hover:text-blue-900 inline-flex items-center"
                    >
                      View
                      <ChevronRight className="h-4 w-4 ml-1" />
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
