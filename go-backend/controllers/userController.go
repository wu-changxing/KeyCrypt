
package controllers

import (
    "KeyCrypt/models"
    "KeyCrypt/utils"
    "github.com/gin-gonic/gin"
    "net/http"
)

func BatchRegister(c *gin.Context) {
    var request models.RegisterRequest
    if err := c.BindJSON(&request); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // TODO: Add logic to process the registration of each user in the request.RegisterRequests
    // This can include saving user details to a database and generating tokens for each user.

    // Dummy response: Generate a token for each user
    tokens := make(map[string]string)
    for _, user := range request.RegisterRequests {
        tokens[user.Platform] = utils.GenerateToken() // Each user gets a unique token
    }

    c.JSON(http.StatusOK, gin.H{"data": tokens, "success": true})
}
func BatchUserInfo(c *gin.Context) {
    var request models.UserInfoBatchRequest
    if err := c.BindJSON(&request); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // TODO: Process the batch user info request.
    // This may involve fetching or updating user information in a database.
    // The following code is a placeholder and should be replaced with actual logic.

    var users []models.UserInfo
    for _, userInfo := range request.BatchVOList {
        // Fetch or update user info based on userInfo data
        // Add logic here...

        // Append updated/fetched user info to the response
        users = append(users, userInfo) // This should be the updated user info
    }

    // Send the response back
    c.JSON(http.StatusOK, models.UserInfoBatchResponse{Users: users})
}
