{
  flake.modules.nixos.obelisk = { pkgs, ... }: {
    services.obelisk.deploymentConfig = {
      activity_js = [{
        name = "step";
        location = pkgs.writeText "step.js" /* js */ ''
          export default async function step(idx, sleep_millis) {
            console.log(`Step ''${idx} started`);
            await new Promise(r => setTimeout(r, Number(sleep_millis)));
            console.log(`Step ''${idx} completed`);
            return String(idx);
          }
        '';
        ffqn = "tutorial:demo/activity.step";
        params = [
          { name = "idx"; type = "u64"; }
          { name = "sleep-millis"; type = "u64"; }
        ];
        return_type = "result<string>";
        exec.lock_expiry.seconds = 10;
      }];

      workflow_js = [{
        name = "serial";
        location = pkgs.writeText "serial.js" /* js */ ''
          export default function serial() {
            let acc = 0;
            for (let i = 0; i < 10; i++) {
              obelisk.sleep({ seconds: 1 });
              const result = obelisk.call("tutorial:demo/activity.step", [i, i * 200]);
              acc += Number(result);
              console.log(`step(''${i})=''${result}`);
            }
            console.log(`serial completed ''${acc}`);
            return String(acc);
          }
        '';
        ffqn = "tutorial:demo/workflow.serial";
        params = [ ];
        return_type = "result<string, string>";
      }];

      webhook_endpoint_js = [{
        name = "webhook";
        location = pkgs.writeText "tutorial.js" /* js */ ''
          export default function handle(request) {
            const url = new URL(request.url);
            const path = url.pathname;
            console.log(`Handling request: ''${path}`);

            if (path === "/serial") {
              const result = obelisk.call("tutorial:demo/workflow.serial", []);
              return new Response(`serial workflow completed ''${result}`, { status: 200 });
            }
            return new Response("not found\ntry /serial", { status: 404 });
          }
        '';
        routes = [ "/*" ];
      }];
    };
  };
}
