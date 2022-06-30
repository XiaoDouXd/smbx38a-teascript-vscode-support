// ================================================================
// 客户端初始化和设置
// ================================================================

import * as path from 'path';
import { workspace, ExtensionContext } from 'vscode';
import {
	LanguageClient,
	LanguageClientOptions,
	ServerOptions,
	TransportKind
} from 'vscode-languageclient/node';

// 声明语言客户端
// 该变量会在 activate 函数中被实例化
let client: LanguageClient;

// ---------------------------------------------------------------- 生命周期函数
// LSP框架中的客户端做的事并不多
// 只是主要用于调整服务端的
// 大部分的内容还是要在服务端书写
export function activate(context: ExtensionContext) {

	// 启动测试
	console.log("log: smbxtea extension activate!");
	
	// 调试设置
	// --inspect=6009: runs the server in Node's Inspector mode so VS Code can attach to the server for debugging
	const debugOptions = { execArgv: ['--nolazy', '--inspect=6009'] };

	// 服务端配置信息
	// 对于 Node 形式的插件，只需要定义入口文件即可，vscode 会帮我们管理好进程的状态
	const serverModule = context.asAbsolutePath(
		path.join('server', 'out', 'server.js')
	);
	const serverOptions: ServerOptions = {
		run: { module: serverModule, transport: TransportKind.ipc },
		debug: {
			module: serverModule,
			transport: TransportKind.ipc,
			options: debugOptions
		}
	};

	// 一些客户端设置
	const clientOptions: LanguageClientOptions = {
		// 定义插件在什么时候生效
		documentSelector: [{ scheme: 'file', language: 'smbxtea' }],
		synchronize: {
			// Notify the server about file changes to '.clientrc files contained in the workspace
			fileEvents: workspace.createFileSystemWatcher('**/.clientrc')
		}
	};

	// 创建客户端实例
	client = new LanguageClient(
		'smbxteaLanguageServer',
		'SMBXTea Language Server',
		serverOptions,
		clientOptions
	);

	// 开启语言客户端
	// 该方法运行时会直接开启服务端
	client.start();
}

export function deactivate(): Thenable<void> | undefined {
	if (!client) {
		return undefined;
	}
	return client.stop();
}
