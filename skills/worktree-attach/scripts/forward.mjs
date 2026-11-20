#!/usr/bin/env node
// Raw TCP forwarder: localhost:<port> -> <host>:<port>.
// Browser agents may only type test logins on localhost, so a worktree's dev
// server on <instance-host>:<port> is opened through this instead.
// Raw TCP keeps vite's HMR websocket working; connections open lazily, so it
// can start before the dev server does.
//
//   node forward.mjs my-instance.local 5360   # app at http://localhost:5360/
import net from 'node:net';

const [host, port] = process.argv.slice(2);
if (!host || !port) {
    console.error('usage: forward.mjs <host> <port>');
    process.exit(2);
}

net.createServer((client) => {
    const upstream = net.connect(Number(port), host);
    client.pipe(upstream).pipe(client);
    client.on('error', () => upstream.destroy());
    upstream.on('error', () => client.destroy());
}).listen(Number(port), '127.0.0.1', () => {
    console.log(`forwarding localhost:${port} -> ${host}:${port}`);
});
