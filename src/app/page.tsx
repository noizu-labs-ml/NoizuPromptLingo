import { ScrollProgress } from "@/components/ScrollProgress";
import { HeroSequence, HeroBackground } from "@/components/sequences/HeroSequence";
import { ProjectsSequence } from "@/components/sequences/ProjectsSequence";
import { ServicesSequence } from "@/components/sequences/ServicesSequence";
import { TestimonialsSequence } from "@/components/sequences/TestimonialsSequence";
import { CTASequence } from "@/components/sequences/CTASequence";

const services = [
  {
    title: "Fractional CTO",
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" d="M2.25 21h19.5m-18-18v18m10.5-18v18m6-13.5V21M6.75 6.75h.75m-.75 3h.75m-.75 3h.75m3-6h.75m-.75 3h.75m-.75 3h.75M6.75 21v-3.375c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21M3 3h12m-.75 4.5H21m-3.75 0h.008v.008h-.008V7.5zm0 3h.008v.008h-.008V10.5z" />
      </svg>
    ),
    items: [
      "Strategic technology leadership for startups and SMEs",
      "Technology roadmaps aligned with business goals",
      "Technology budget and resource optimization",
      "Risk assessment and decision-making guidance",
      "Building high-performing technology teams",
    ],
  },
  {
    title: "Principal Engineer",
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" d="M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5" />
      </svg>
    ),
    items: [
      "Deep technical expertise for complex engineering challenges",
      "Scalable and reliable system architecture",
      "Mentoring and guiding development teams",
      "Code reviews and engineering best practices",
      "Solving critical technical problems",
    ],
  },
  {
    title: "Quality Control",
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z" />
      </svg>
    ),
    items: [
      "Comprehensive QA processes and methodologies",
      "Manual and automated testing",
      "Test automation and brutal test strategies",
      "Linters, static analysis, and release pipelines",
      "Change management and isolated testing",
    ],
  },
  {
    title: "Code Audit & Threat Modeling",
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
      </svg>
    ),
    items: [
      "Vulnerability and security risk identification",
      "Coding standards adherence review",
      "Performance and maintainability optimization",
      "Detailed reports and remediation recommendations",
    ],
  },
  {
    title: "Service Readiness",
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" />
      </svg>
    ),
    items: [
      "Metrics and monitoring for service health",
      "Performance tuning across full stack",
      "Load testing and capacity planning",
      "Incident response and disaster recovery",
      "Release pipeline design",
    ],
  },
  {
    title: "Development",
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" d="M6.75 7.5l3 2.25-3 2.25m4.5 0h3m-9 8.25h13.5A2.25 2.25 0 0021 18V6a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 6v12a2.25 2.25 0 002.25 2.25z" />
      </svg>
    ),
    items: [
      "LiveView/backend development for performance",
      "Stress testing and scalability analysis",
      "Caching strategies and database optimization",
      "Integration with external services and APIs",
    ],
  },
  {
    title: "Technical Project Management",
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" d="M18 18.72a9.094 9.094 0 003.741-.479 3 3 0 00-4.682-2.72m.94 3.198l.001.031c0 .225-.012.447-.037.666A11.944 11.944 0 0112 21c-2.17 0-4.207-.576-5.963-1.584A6.062 6.062 0 016 18.719m12 0a5.971 5.971 0 00-.941-3.197m0 0A5.995 5.995 0 0012 12.75a5.995 5.995 0 00-5.058 2.772m0 0a3 3 0 00-4.681 2.72 8.986 8.986 0 003.74.477m.94-3.197a5.971 5.971 0 00-.94 3.197M15 6.75a3 3 0 11-6 0 3 3 0 016 0zm6 3a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0zm-13.5 0a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0z" />
      </svg>
    ),
    items: [
      "Hiring skilled developers and engineers",
      "Offshore team management and collaboration",
      "Mentoring and team guidance",
      "Innovation culture and continuous improvement",
    ],
  },
  {
    title: "IoT & Embedded Systems",
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" d="M8.288 15.038a5.25 5.25 0 017.424 0M5.106 11.856c3.807-3.808 9.98-3.808 13.788 0M1.924 8.674c5.565-5.565 14.587-5.565 20.152 0M12.53 18.22l-.53.53-.53-.53a.75.75 0 011.06 0z" />
      </svg>
    ),
    items: [
      "Espressif & ARM embedded C (nonos/rtos)",
      "ECC for reliable data transmission",
      "Secure firmware updates and key management",
      "Fleet management and OTA monitoring",
      "Memory optimization and data compression",
    ],
  },
];

const recommendations = [
  {
    feedback:
      "Keith came out of no where and saved Greatnonprofits with his dedication and passion to help make a difference in the world. In my 25 year career I have not met better. He ensures systems are built in a way that allows the best Performance, Scalability, and Extensibility with an NPO budget in mind.",
    name: "James Rowley",
    title: "Executive in SaaS Products",
  },
  {
    feedback:
      "Keith is energetic, outspoken, hardworking and dedicated. He has a very good grasp of the database tiers, has never failed to get a job done, and is always happy to listen to constructive feedback and advice.",
    name: "Laine Campbell",
    title: "Production Engineering Director, Meta",
  },
  {
    feedback:
      "I've been really impressed by the wealth of Keith's talents and resources. His ethics, his thoroughness, and his ability to work with others are very much valued. He's a rare find as a Chief Architect who is both practical and has the big picture in mind.",
    name: "Perla Ni",
    title: "Founder, Greatnonprofits.org",
  },
  {
    feedback:
      "Keith demonstrated a strong passion for shipping great software, had the right balance of technical insight and a drive for process, with the ability to think big picture at the product scope, as well as drill down deep into specific feature areas.",
    name: "Ankur Sinha",
    title: "CTO at Remitly",
  },
  {
    feedback:
      "Working with Keith was a great experience. He is always focused on shipping great software, and is willing to do what needs to be done to make that happen. This includes things like setting up a continuous delivery system and a test cluster to run UI tests.",
    name: "Tom Macie",
    title: "Member of Technical Staff, Anthropic",
  },
  {
    feedback:
      "Keith is truly passionate about improving the way we ship software. Some examples include building the continuous delivery system and delivering on the custom asserts library.",
    name: "Gary Keong",
    title: "Senior Engineering Manager, Microsoft",
  },
  {
    feedback:
      "Keith is a fantastic out of the box architectural thinker. He is able to look at a problem and play with it until he has created a solid logical plan of attack. He has a great work ethic, is very detailed in his approach, and fulfills his commitments and promises.",
    name: "Stephen Mayer",
    title: "Staff Engineer at Learn To Win",
  },
  {
    feedback:
      "Best lead developer I've worked with. Very friendly, always calm -- makes him a great leader. He's always there for his team even after office hours. A great mentor, always giving good advices to help us with our tasks.",
    name: "Jayson Basanes",
    title: "Engineering Manager, Automattic",
  },
  {
    feedback:
      "When a problem comes up, Keith takes his time to research the best solution possible, and not jump to the quick fix. Through his help and recommendations, Kaplan was able to start continuous integration with test suites verifying that the code is up to our established standards.",
    name: "Richard Williams",
    title: "Director of Software Engineering at Education Dynamics",
  },
];

const featuredProjects = [
  {
    name: "GenAI",
    description: "Multi-model/provider client for running inference against various LLMs with unified API handling.",
    tags: ["Elixir", "AI"],
    href: "https://github.com/noizu-labs-ml/genai",
  },
  {
    name: "NPL (Noizu Prompt Lingua)",
    description: "Conventions and system prompts for improving predictability of model output and middleware reliability.",
    tags: ["Prompting", "AI"],
    href: "https://github.com/noizu-labs-ml/NoizuPromptLingo",
  },
  {
    name: "Noizu Intellect",
    description: "Advanced multi-agent system for composing virtual workgroups with multiple models and channels.",
    tags: ["Elixir", "AI"],
    href: "https://github.com/noizu-labs/intellect",
  },
  {
    name: "FragmentedKeys",
    description: "Cache key management library for fragmented caching strategies. Ported to Java and Swift.",
    tags: ["PHP", "Java", "Swift"],
    href: "https://github.com/noizu/fragmented-keys",
  },
  {
    name: "Rule Engine",
    description: "Protocols for DB/config-driven runtime rule engines, ideal for hooking GenAI-driven site behavior.",
    tags: ["Elixir"],
    href: "https://github.com/noizu-labs/RuleEngine",
  },
  {
    name: "TrieGen",
    description: "C# tool generating precompiled trie data structures for blazingly fast UART and streaming JSON parsing.",
    tags: ["Embedded C", "C#"],
    href: "https://github.com/noizu-labs/trie_gen",
  },
];

export default function Home() {
  return (
    <>
      <ScrollProgress />
      <HeroBackground />
      {/* Ascending z-index so each section stacks above the previous.
          clip-path: inset(0) creates isolated stacking contexts per section,
          so explicit z-index is required — DOM order alone is insufficient. */}
      <HeroSequence zIndex={1} />
      <ProjectsSequence projects={featuredProjects} zIndex={2} />
      <ServicesSequence services={services} zIndex={3} />
      <TestimonialsSequence recommendations={recommendations} zIndex={4} />
      <CTASequence zIndex={5} />
    </>
  );
}
