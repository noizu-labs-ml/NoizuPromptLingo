'use client';

import { useEffect, useState, useCallback } from 'react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import {
  Plus,
  RefreshCw,
  ChevronRight,
  ArrowLeft,
  Bell,
} from 'lucide-react';
import {
  TaskQueue,
  Task,
  TaskEvent,
  getTaskQueue,
  listTasks,
  createTask,
  subscribeToQueueStream,
} from '@/lib/api';
import { StatusBadge, PriorityBadge, ComplexityBadge } from '@/components/Badge';
import { Button } from '@/components/Button';
import { Input, Textarea, Select } from '@/components/Input';

export default function TaskQueueDetailPage() {
  const params = useParams();
  const queueId = Number(params.queueId);

  const [queue, setQueue] = useState<TaskQueue | null>(null);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [notifications, setNotifications] = useState<TaskEvent[]>([]);
  const [isStreaming, setIsStreaming] = useState(false);

  const [formData, setFormData] = useState({
    title: '',
    description: '',
    acceptance_criteria: '',
    priority: '1',
    deadline: '',
    assigned_to: '',
  });

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      const [queueData, tasksData] = await Promise.all([
        getTaskQueue(queueId),
        listTasks(queueId),
      ]);
      setQueue(queueData);
      setTasks(tasksData);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load data');
    } finally {
      setLoading(false);
    }
  }, [queueId]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // SSE stream subscription
  useEffect(() => {
    if (!queueId || isStreaming) return;

    setIsStreaming(true);
    const unsubscribe = subscribeToQueueStream(
      queueId,
      (event) => {
        setNotifications((prev) => [event, ...prev].slice(0, 10));
        // Refresh tasks on important events
        if (['task_created', 'status_changed'].includes(event.event_type)) {
          fetchData();
        }
      },
      (err) => {
        console.error('Stream error:', err);
        setIsStreaming(false);
      }
    );

    return () => {
      unsubscribe();
      setIsStreaming(false);
    };
  }, [queueId, fetchData, isStreaming]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.title.trim()) return;

    try {
      setSubmitting(true);
      await createTask(queueId, {
        title: formData.title.trim(),
        description: formData.description.trim() || undefined,
        acceptance_criteria: formData.acceptance_criteria.trim() || undefined,
        priority: Number(formData.priority),
        deadline: formData.deadline || undefined,
        assigned_to: formData.assigned_to.trim() || undefined,
      });
      setFormData({
        title: '',
        description: '',
        acceptance_criteria: '',
        priority: '1',
        deadline: '',
        assigned_to: '',
      });
      setShowForm(false);
      fetchData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create task');
    } finally {
      setSubmitting(false);
    }
  };

  const groupedTasks = {
    pending: tasks.filter((t) => t.status === 'pending'),
    in_progress: tasks.filter((t) => t.status === 'in_progress'),
    blocked: tasks.filter((t) => t.status === 'blocked'),
    review: tasks.filter((t) => t.status === 'review'),
    done: tasks.filter((t) => t.status === 'done'),
  };

  if (loading && !queue) {
    return (
      <div className="text-center py-12">
        <RefreshCw className="h-8 w-8 animate-spin mx-auto text-gray-400" />
        <p className="mt-2 text-gray-500">Loading queue...</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-start">
        <div>
          <Link
            href="/tasks"
            className="text-sm text-gray-500 hover:text-gray-700 inline-flex items-center mb-2"
          >
            <ArrowLeft className="h-4 w-4 mr-1" />
            Back to Queues
          </Link>
          <h1 className="text-2xl font-bold text-gray-900">{queue?.name}</h1>
          {queue?.description && (
            <p className="text-gray-600">{queue.description}</p>
          )}
        </div>
        <div className="flex space-x-2">
          {notifications.length > 0 && (
            <div className="relative">
              <Button variant="ghost">
                <Bell className="h-4 w-4" />
                <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                  {notifications.length}
                </span>
              </Button>
            </div>
          )}
          <Button variant="ghost" onClick={fetchData} disabled={loading}>
            <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
          <Button onClick={() => setShowForm(!showForm)}>
            <Plus className="h-4 w-4 mr-2" />
            New Task
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
          <h2 className="text-lg font-semibold mb-4">Create Task</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              label="Title"
              placeholder="Task title"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              required
            />
            <Textarea
              label="Description"
              placeholder="Describe the task"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            />
            <Textarea
              label="Acceptance Criteria"
              placeholder="What needs to be true for this task to be complete?"
              value={formData.acceptance_criteria}
              onChange={(e) =>
                setFormData({ ...formData, acceptance_criteria: e.target.value })
              }
            />
            <div className="grid grid-cols-2 gap-4">
              <Select
                label="Priority"
                value={formData.priority}
                onChange={(e) => setFormData({ ...formData, priority: e.target.value })}
                options={[
                  { value: '0', label: 'Low' },
                  { value: '1', label: 'Normal' },
                  { value: '2', label: 'High' },
                  { value: '3', label: 'Urgent' },
                ]}
              />
              <Input
                label="Deadline"
                type="datetime-local"
                value={formData.deadline}
                onChange={(e) => setFormData({ ...formData, deadline: e.target.value })}
              />
            </div>
            <Input
              label="Assigned To"
              placeholder="Agent or person"
              value={formData.assigned_to}
              onChange={(e) => setFormData({ ...formData, assigned_to: e.target.value })}
            />
            <div className="flex space-x-2">
              <Button type="submit" disabled={submitting || !formData.title.trim()}>
                {submitting ? 'Creating...' : 'Create Task'}
              </Button>
              <Button type="button" variant="secondary" onClick={() => setShowForm(false)}>
                Cancel
              </Button>
            </div>
          </form>
        </div>
      )}

      {/* Task columns */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-4">
        {(['pending', 'in_progress', 'blocked', 'review', 'done'] as const).map((status) => (
          <div key={status} className="bg-gray-50 rounded-lg p-4">
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-sm font-medium text-gray-700 capitalize">
                {status.replace('_', ' ')}
              </h3>
              <span className="text-xs bg-gray-200 text-gray-600 px-2 py-1 rounded-full">
                {groupedTasks[status].length}
              </span>
            </div>
            <div className="space-y-2">
              {groupedTasks[status].map((task) => (
                <Link
                  key={task.id}
                  href={`/tasks/${queueId}/task/${task.id}`}
                  className="block bg-white rounded-lg p-3 shadow-sm border hover:shadow-md transition-shadow"
                >
                  <div className="flex justify-between items-start mb-2">
                    <span className="text-sm font-medium text-gray-900 line-clamp-2">
                      {task.title}
                    </span>
                    <ChevronRight className="h-4 w-4 text-gray-400 flex-shrink-0" />
                  </div>
                  <div className="flex flex-wrap gap-1">
                    <PriorityBadge priority={task.priority} />
                    {task.complexity && <ComplexityBadge complexity={task.complexity} />}
                  </div>
                  {task.assigned_to && (
                    <div className="mt-2 text-xs text-gray-500">
                      Assigned: {task.assigned_to}
                    </div>
                  )}
                  {task.deadline && (
                    <div className="mt-1 text-xs text-gray-500">
                      Due: {new Date(task.deadline).toLocaleDateString()}
                    </div>
                  )}
                </Link>
              ))}
              {groupedTasks[status].length === 0 && (
                <div className="text-center py-4 text-gray-400 text-sm">No tasks</div>
              )}
            </div>
          </div>
        ))}
      </div>

      {/* Recent notifications */}
      {notifications.length > 0 && (
        <div className="bg-white rounded-lg shadow-sm border p-4">
          <h3 className="text-sm font-medium text-gray-700 mb-3">Recent Activity</h3>
          <div className="space-y-2">
            {notifications.map((event, idx) => (
              <div key={idx} className="text-sm text-gray-600 flex items-start">
                <span className="w-2 h-2 bg-blue-400 rounded-full mt-1.5 mr-2 flex-shrink-0" />
                <span>
                  <span className="font-medium">{event.event_type}</span>
                  {event.summary && `: ${event.summary}`}
                  <span className="text-gray-400 ml-2">
                    {new Date(event.created_at).toLocaleTimeString()}
                  </span>
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
