#include "crow.h"
#include <iostream>

int main()
{
    crow::SimpleApp app;

    CROW_ROUTE(app, "/")([](){
        return "Hello world! This is MathDataWork C++ Backend.";
    });

    CROW_ROUTE(app, "/api/users")([](){
        crow::json::wvalue x;
        x["status"] = "success";
        x["message"] = "C++ Backend is running. User data will be here.";
        return x;
    });

    app.port(8080).multithreaded().run();
}