import { createRoot } from "react-dom/client";
import "./shaders/community.css";
const mods = import.meta.glob("./package-components/*.ts");
const q = new URLSearchParams(location.search);
const name = q.get("c") || "WarpFieldBackground";
const props = q.get("p") ? JSON.parse(q.get("p")!) : {};
const load = mods[`./package-components/${name}.ts`];
if (!load) { document.title = "missing"; }
else load().then((m: any) => {
  const C = m[name];
  createRoot(document.getElementById("root")!).render(<div style={{ position: "fixed", inset: 0 }}><C {...props} style={{ width: "100%", height: "100%" }} className="capture" /></div>);
  setTimeout(() => { document.title = "done"; }, 6000);
});
