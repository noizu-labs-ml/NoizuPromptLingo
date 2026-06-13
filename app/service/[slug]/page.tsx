import { services, getServiceBySlug } from "@/lib/services";
import { ServiceViewer } from "@/components/ServiceViewer";
import Link from "next/link";

export function generateStaticParams() {
  return services.map((s) => ({ slug: s.slug }));
}

export default async function ServicePage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const service = getServiceBySlug(slug);

  if (!service) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <p className="text-muted text-lg mb-3">Service not found</p>
          <Link href="/" className="text-accent hover:text-accent-hover text-sm">
            Back to dashboard
          </Link>
        </div>
      </div>
    );
  }

  return <ServiceViewer service={service} />;
}
