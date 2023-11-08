package routes

import (
    "KeyCrypt/controllers"
    "github.com/gin-gonic/gin"
)

func Setup(router *gin.Engine) {
    router.POST("/user/register/batch", controllers.BatchRegister)
    router.POST("/user/info/batch", controllers.BatchUserInfo) // New endpoint
}
