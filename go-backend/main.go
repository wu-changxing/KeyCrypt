
package main

import (
    "KeyCrypt/routes"
    "github.com/gin-gonic/gin"
)

func main() {
    router := gin.Default()

    // Setup routes
    routes.Setup(router)

    router.Run(":8080")
}

