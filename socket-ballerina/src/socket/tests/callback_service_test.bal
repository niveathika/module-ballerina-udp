// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/log;
import ballerina/test;

http:Client clientEndpoint = new ("http://localhost:58291");

@test:Config {
}
function testHttpClientEcho() {
    http:Request req = new;
    req.addHeader("Content-Type", "text/plain");
    string requestMessage = "Hello Ballerina";
    var response = clientEndpoint->post("/echo", requestMessage);

    if (response is http:Response) {
        test:assertEquals(response.statusCode, 202, "Unexpected response code");
    } else {
        string? errMsg = response.detail()?.message;
        test:assertFail(msg = errMsg is string ? errMsg : "Error in http post request");
    }
}

@test:Config {
    dependsOn: ["testHttpClientEcho"]
}
function testSocketServerJoinLeave() {
    int i = 0;
    while(i < 5) {
        passMessageToSocketServer("Hello Ballerina\n", 61598);
        i += 1;
    }
}

@test:Config {
    dependsOn: ["testSocketServerJoinLeave"]
}
function testSocketReadTimeout() {
   passMessageToSocketServer("Hello Ballerina", 61599);
}

function passMessageToSocketServer(string msg, int port) {
    Client socketClient = new ({host: "localhost", port: port});
    byte[] msgByteArray = msg.toBytes();
    var writeResult = socketClient->write(msgByteArray);
    if (writeResult is int) {
        log:printInfo("Number of bytes written: " + writeResult.toString());
    } else {
        string? errMsg = writeResult.detail()?.message;
        test:assertFail(msg = errMsg is string ? errMsg : "Error in socket write");
    }
    closeClientConnection(socketClient);
}
