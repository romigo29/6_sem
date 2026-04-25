package main

type Celebrity struct {
	Id           int    `json:"id" gorm:"primaryKey;column:Id"`
	FullName     string `json:"fullName" gorm:"column:FullName"`
	Nationality  string `json:"nationality" gorm:"column:Nationality"`
	ReqPhotoPath string `json:"reqPhotoPath" gorm:"column:ReqPhotoPath"`
}
