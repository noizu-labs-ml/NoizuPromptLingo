//! Assemble `docker run` argument vectors. Pure data → args; no execution here.

/// A volume mount.
#[derive(Debug, Clone)]
pub struct Mount {
    pub source: String,
    pub target: String,
    pub read_only: bool,
}

/// A fully described interactive `docker run` invocation.
#[derive(Debug, Clone)]
pub struct RunSpec {
    pub image: String,
    /// Container name (also used as hostname).
    pub name: String,
    pub workdir: String,
    pub mounts: Vec<Mount>,
    /// Ordered environment variables.
    pub env: Vec<(String, String)>,
    /// (host_port, container_port, protocol, bind_addr)
    pub ports: Vec<(u16, u16, String, Option<String>)>,
    /// User-defined docker network to attach (e.g. compose infra network).
    pub network: Option<String>,
    /// Whether the container may reach the public internet.
    pub internet_access: bool,
    /// Remove the container on exit.
    pub remove: bool,
    /// Override the image entrypoint (e.g. `bash`). `None` keeps the image's.
    pub entrypoint: Option<String>,
    /// The command + args run inside the container.
    pub command: Vec<String>,
}

impl RunSpec {
    /// Build the `docker run ...` argument vector (excluding the leading
    /// `docker`).
    pub fn to_args(&self) -> Vec<String> {
        let mut a: Vec<String> = vec!["run".into(), "-it".into()];
        if self.remove {
            a.push("--rm".into());
        }
        a.push("--name".into());
        a.push(self.name.clone());

        // Network policy. An explicit network wins; otherwise `none` enforces no
        // egress when internet access is disabled (best-effort for `docker run`;
        // true isolation comes with the compose `internal` network milestone).
        match (&self.network, self.internet_access) {
            (Some(net), _) => {
                a.push("--network".into());
                a.push(net.clone());
            }
            (None, false) => {
                a.push("--network".into());
                a.push("none".into());
            }
            (None, true) => {}
        }

        a.push("--workdir".into());
        a.push(self.workdir.clone());

        for m in &self.mounts {
            let ro = if m.read_only { ":ro" } else { "" };
            a.push("-v".into());
            a.push(format!("{}:{}{}", m.source, m.target, ro));
        }

        for (k, v) in &self.env {
            a.push("-e".into());
            a.push(format!("{k}={v}"));
        }

        for (host, container, proto, bind) in &self.ports {
            a.push("-p".into());
            let spec = match bind {
                Some(addr) => format!("{addr}:{host}:{container}/{proto}"),
                None => format!("{host}:{container}/{proto}"),
            };
            a.push(spec);
        }

        if let Some(ep) = &self.entrypoint {
            a.push("--entrypoint".into());
            a.push(ep.clone());
        }

        a.push(self.image.clone());
        a.extend(self.command.iter().cloned());
        a
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn spec() -> RunSpec {
        RunSpec {
            image: "agent-sandbox:node".into(),
            name: "as-feature".into(),
            workdir: "/work".into(),
            mounts: vec![Mount {
                source: "/host/wt".into(),
                target: "/work".into(),
                read_only: false,
            }],
            env: vec![("FOO".into(), "bar".into())],
            ports: vec![(3000, 3000, "tcp".into(), Some("127.0.0.1".into()))],
            network: None,
            internet_access: false,
            remove: true,
            entrypoint: None,
            command: vec!["bash".into(), "-l".into()],
        }
    }

    #[test]
    fn assembles_interactive_run() {
        let args = spec().to_args();
        let joined = args.join(" ");
        assert!(joined.starts_with("run -it --rm --name as-feature"));
        assert!(joined.contains("--network none")); // internet disabled
        assert!(joined.contains("-v /host/wt:/work"));
        assert!(joined.contains("-e FOO=bar"));
        assert!(joined.contains("-p 127.0.0.1:3000:3000/tcp"));
        assert!(joined.ends_with("agent-sandbox:node bash -l"));
    }

    #[test]
    fn explicit_network_overrides_none() {
        let mut s = spec();
        s.network = Some("agent-sandbox".into());
        let joined = s.to_args().join(" ");
        assert!(joined.contains("--network agent-sandbox"));
        assert!(!joined.contains("--network none"));
    }

    #[test]
    fn internet_access_omits_network_flag() {
        let mut s = spec();
        s.internet_access = true;
        let joined = s.to_args().join(" ");
        assert!(!joined.contains("--network"));
    }

    #[test]
    fn read_only_mount_appends_ro() {
        let mut s = spec();
        s.mounts[0].read_only = true;
        let joined = s.to_args().join(" ");
        assert!(joined.contains(":/work:ro"));
    }

    #[test]
    fn port_without_bind_has_no_addr_prefix() {
        let mut s = spec();
        s.ports = vec![(8080, 80, "tcp".into(), None)];
        let joined = s.to_args().join(" ");
        assert!(joined.contains("-p 8080:80/tcp"));
        assert!(!joined.contains("127.0.0.1"));
    }

    #[test]
    fn no_remove_flag_when_disabled() {
        let mut s = spec();
        s.remove = false;
        let joined = s.to_args().join(" ");
        assert!(!joined.contains("--rm"));
    }

    #[test]
    fn entrypoint_is_included_when_set() {
        let mut s = spec();
        s.entrypoint = Some("sh".into());
        let joined = s.to_args().join(" ");
        assert!(joined.contains("--entrypoint sh"));
    }
}
