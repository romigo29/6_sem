package main

// Celebrity представляет сущность знаменитости
// @Description Модель данных знаменитости
type Celebrity struct {
	Id           int    `json:"id" example:"1"`
	FullName     string `json:"fullName" example:"John Doe"`
	Nationality  string `json:"nationality" example:"American"`
	ReqPhotoPath string `json:"reqPhotoPath" example:"/photos/john_doe.jpg"`
}