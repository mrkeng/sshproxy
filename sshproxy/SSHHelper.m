//
//  SSHHelper.m
//  sshproxy
//
//  Created by Brant Young on 15/5/13.
//  Copyright (c) 2013 Charm Studio. All rights reserved.
//

#import "SSHHelper.h"

@implementation SSHHelper


+ (NSMutableArray*) getConnectArgs
{
    NSString* userHome = NSHomeDirectory();
    NSString* knownHostFile= [userHome stringByAppendingPathComponent:@".sshproxy_known_hosts"];
    NSString* identityFile= [userHome stringByAppendingPathComponent:@".sshproxy_identity"];
    //    NSString* configFile= [userHome stringByAppendingPathComponent:@".sshproxy_config"];
    
    NSMutableArray *arguments = [NSMutableArray arrayWithObjects:
                                 [NSString stringWithFormat:@"-oUserKnownHostsFile=\"%@\"", knownHostFile],
                                 [NSString stringWithFormat:@"-oGlobalKnownHostsFile=\"%@\"", knownHostFile],
                                 [NSString stringWithFormat:@"-oIdentityFile=\"%@\"", identityFile],
                                 // TODO:
                                 //                        [NSString stringWithFormat:@"-F \"%@\"", configFile],
                                 @"-oIdentitiesOnly=yes",
                                 @"-oPubkeyAuthentication=no",
                                 @"-T", @"-2", @"-a",
                                 @"-oConnectTimeout=8", @"-oConnectionAttempts=3",
                                 @"-oServerAliveInterval=8", @"-oServerAliveCountMax=1",
                                 @"-oStrictHostKeyChecking=no", @"-oExitOnForwardFailure=yes",
                                 @"-oLogLevel=DEBUG",
                                 @"-oPreferredAuthentications=password",
                                 nil];
    
    return arguments;
}

// for ProxyCommand Env
+ (NSMutableDictionary*) getProxyCommandEnv
{
    NSMutableDictionary* env = [NSMutableDictionary dictionary];
    
    BOOL proxyCommand = [[NSUserDefaults standardUserDefaults] boolForKey:@"proxy_command"];
    BOOL proxyCommandAuth = [[NSUserDefaults standardUserDefaults] boolForKey:@"proxy_command_auth"];
    NSString* proxyCommandUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"proxy_command_username"];
    NSString* proxyCommandPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"proxy_command_password"];
    
    if (proxyCommand && proxyCommandAuth) {
        if (proxyCommandUsername) {
            [env setValue:@"YES" forKey:@"HTTP_PROXY_FORCE_AUTH"];
            [env setValue:proxyCommandUsername forKey:@"CONNECT_USER"];
            if (proxyCommandPassword) {
                [env setValue:proxyCommandPassword forKey:@"CONNECT_PASSWORD"];
            }
        }
    }
    
    return env;
}

// for ProxyCommand
+ (NSString*) getProxyCommandStr
{
    NSString *connectPath = [NSBundle pathForResource:@"connect" ofType:@""
                                          inDirectory:[[NSBundle mainBundle] bundlePath]];
    
    BOOL proxyCommand = [[NSUserDefaults standardUserDefaults] boolForKey:@"proxy_command"];
    int proxyCommandType = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"proxy_command_type"];
    NSString* proxyCommandHost = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"proxy_command_host"];
    int proxyCommandPort = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"proxy_command_port"];
    
    NSString* proxyCommandStr = nil;
    if (proxyCommand){
        if (proxyCommandHost) {
            NSString* proxyType = @"-S";
            
            switch (proxyCommandType) {
                case 0:
                    proxyType = @"-5 -S";
                    break;
                case 1:
                    proxyType = @"-4 -S";
                    break;
                case 2:
                    proxyType = @"-H";
                    break;
            }
            
            if (proxyCommandPort<=0 || proxyCommandPort>65535) {
                proxyCommandPort = 1080;
            }
            
            proxyCommandStr = [NSString stringWithFormat:@"-oProxyCommand=\"%@\" -d -w 8 %@ %@:%d %@", connectPath, proxyType, proxyCommandHost, proxyCommandPort, @"%h %p"];
        }
    }
    
    return proxyCommandStr;
}

@end