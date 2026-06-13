import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { apiFetch } from "../hooks/useApi.js";

interface Candidate {
  type: string;
  startIndex: number;
  endIndex: number;
  confidence: number;
  description: string;
}

interface Artifact {
  type: string;
  name: string;
  description: string;
  content: string;
}

export function Convert() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [candidates, setCandidates] = useState<Candidate[]>([]);
  const [selectedType, setSelectedType] = useState<string>("agent");
  const [range, setRange] = useState<[number, number]>([0, 0]);
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [artifact, setArtifact] = useState<Artifact | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!id) return;
    apiFetch<{ data: Candidate[] }>(`/conversations/${id}/candidates`)
      .then((res) => { setCandidates(res.data); setLoading(false); })
      .catch(() => setLoading(false));
  }, [id]);

  const handleGenerate = async () => {
    const res = await apiFetch<{ data: Artifact }>(`/conversations/${id}/convert`, {
      method: "POST",
      body: JSON.stringify({ type: selectedType, range, name, description }),
    });
    setArtifact(res.data);
    setStep(4);
  };

  const types = ["agent", "skill", "command", "snippet", "runbook"];

  if (loading) return <div className="mx-auto max-w-4xl"><p className="text-sm text-text-muted">Loading...</p></div>;

  return (
    <div className="mx-auto max-w-4xl space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-medium text-text-bright">Convert to Artifact</h1>
        <button onClick={() => navigate(`/thread/${id}`)} className="text-xs text-text-muted hover:text-text-primary">Cancel</button>
      </div>

      {/* Step indicators */}
      <div className="flex gap-2">
        {["Type", "Range", "Configure", "Preview"].map((label, i) => (
          <span key={i} className={`px-3 py-1 rounded-full text-xs ${step === i + 1 ? "bg-glow text-void" : "bg-surface-active text-text-dim"}`}>
            {i + 1}. {label}
          </span>
        ))}
      </div>

      {step === 1 && (
        <div className="space-y-3">
          <h2 className="text-sm font-medium text-text-primary">Select artifact type</h2>
          <div className="grid grid-cols-5 gap-2">
            {types.map((t) => (
              <button
                key={t}
                onClick={() => { setSelectedType(t); setStep(2); }}
                className={`rounded-md border p-3 text-center text-sm capitalize ${
                  selectedType === t ? "border-glow bg-glow-bg text-text-bright" : "border-border-subtle text-text-muted hover:border-glow/30"
                }`}
              >
                {t}
              </button>
            ))}
          </div>
          {candidates.length > 0 && (
            <div className="mt-4">
              <h3 className="text-xs text-text-dim mb-2">Suggested extractions:</h3>
              {candidates.map((c, i) => (
                <button
                  key={i}
                  onClick={() => { setSelectedType(c.type); setRange([c.startIndex, c.endIndex]); setStep(3); }}
                  className="block w-full text-left rounded-md border border-border-subtle p-3 mb-1 hover:border-glow/30"
                >
                  <span className="text-xs text-glow capitalize">{c.type}</span>
                  <span className="text-xs text-text-dim ml-2">{Math.round(c.confidence * 100)}% confidence</span>
                  <p className="text-xs text-text-muted mt-1">{c.description}</p>
                </button>
              ))}
            </div>
          )}
        </div>
      )}

      {step === 2 && (
        <div className="space-y-3">
          <h2 className="text-sm font-medium text-text-primary">Select message range</h2>
          <div className="flex gap-3 items-center">
            <label className="text-xs text-text-dim">Start:</label>
            <input type="number" value={range[0]} onChange={(e) => setRange([Number(e.target.value), range[1]])} className="w-20 rounded bg-canvas px-2 py-1 text-sm text-text-primary border border-border-subtle" />
            <label className="text-xs text-text-dim">End:</label>
            <input type="number" value={range[1]} onChange={(e) => setRange([range[0], Number(e.target.value)])} className="w-20 rounded bg-canvas px-2 py-1 text-sm text-text-primary border border-border-subtle" />
          </div>
          <button onClick={() => setStep(3)} className="rounded bg-glow px-4 py-1.5 text-sm text-void">Next</button>
        </div>
      )}

      {step === 3 && (
        <div className="space-y-3">
          <h2 className="text-sm font-medium text-text-primary">Configure</h2>
          <input type="text" value={name} onChange={(e) => setName(e.target.value)} placeholder="Artifact name..." className="w-full rounded bg-canvas px-3 py-1.5 text-sm text-text-primary border border-border-subtle placeholder:text-text-dim outline-none" />
          <input type="text" value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Description..." className="w-full rounded bg-canvas px-3 py-1.5 text-sm text-text-primary border border-border-subtle placeholder:text-text-dim outline-none" />
          <button onClick={handleGenerate} disabled={!name} className="rounded bg-glow px-4 py-1.5 text-sm text-void disabled:opacity-50">Generate</button>
        </div>
      )}

      {step === 4 && artifact && (
        <div className="space-y-3">
          <h2 className="text-sm font-medium text-text-primary">Preview: {artifact.name}</h2>
          <pre className="rounded-md border border-border-subtle bg-canvas p-4 text-xs text-text-muted overflow-auto max-h-96 whitespace-pre-wrap">
            {artifact.content}
          </pre>
          <div className="flex gap-2">
            <button onClick={() => navigator.clipboard.writeText(artifact.content)} className="rounded bg-glow px-4 py-1.5 text-sm text-void">
              Copy to Clipboard
            </button>
            <button onClick={() => navigate(`/thread/${id}`)} className="rounded bg-surface-active px-4 py-1.5 text-sm text-text-muted">
              Done
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
