
package models
type UserRegistrationData struct {
    PublicKey   string `json:"publicKey"`
    Platform    string `json:"platform"`
    IsAnonymous string `json:"isAnonymous"`
    IMEI        string `json:"imei"`
    Channel     string `json:"channel"`
    ClientCode  string `json:"clientCode"`
    ApplyId     string `json:"applyId"`
    HeadUrl     string `json:"headUrl"`
    Name        string `json:"name"`
}

// RegisterRequest represents the request structure for batch registration.
type RegisterRequest struct {
    RegisterRequests []UserRegistrationData `json:"registerRequests"`
}
// UserInfo represents individual user information.
type UserInfo struct {
    ID             int    `json:"id"`
    Name           string `json:"name"`
    PublicKey      string `json:"publicKey"`
    Platform       string `json:"platform"`
    IsAnonymous    string `json:"isAnonymous"`
    IMEI           string `json:"imei"`
    Channel        string `json:"channel"`
    ClientCode     string `json:"clientCode"`
    ApplyId        string `json:"applyId"`
    HeadUrl        string `json:"headUrl"`
    InviteCode     string `json:"inviteCode"`
    WalletAddress  string `json:"walletAddress"`
}

// UserInfoBatchRequest represents the structure of the batch user info request.
type UserInfoBatchRequest struct {
    BatchVOList []UserInfo `json:"batchVOList"`
}

// UserInfoBatchResponse represents the structure of the batch user info response.
type UserInfoBatchResponse struct {
    Users []UserInfo `json:"data"`
}
