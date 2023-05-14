# prompt-chain.py
import os
import sys

services = sys.argv[1:]

base_dir = "."

nlp_version = os.environ.get("NLP_VERSION")
nlp_file = os.path.join(base_dir, "nlp", f"nlp-{nlp_version}.prompt.md")
virtual_tools_dir = os.path.join(base_dir, "virtual-tools")

# Read the content of nlp-{nlp_version}.prompt.md
with open(nlp_file, "r") as nlp_md:
    content = nlp_md.read()
print(services)
if services == ['all']:
    services = ["gpt-cr","gpt-doc", "gpt-fim", "gpt-git", "gpt-math", "gpt-pm", "gpt-pro", "nb", "pla"]
if services == ['min']:
    services = ["gpt-fim", "gpt-git", "gpt-pro"]


for service in services:
    string = service.upper().replace("-", "_")
    service_version = os.environ.get(f"{string}_VERSION")
    service_dir = os.path.join(virtual_tools_dir, service)
    service_file = os.path.join(service_dir, f"{service}-{service_version}.prompt.md")
    print(service_file)
    with open(service_file, "r") as service_md:
        content += "\n" + service_md.read()

# Write the content to the prompt.chain.md file in the current working directory
output_file = os.path.join(os.getcwd(), "prompt.chain.md")
with open(output_file, "w") as output_md:
    output_md.write(content)

print(f"Combined content saved to {output_file}")
