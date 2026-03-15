package P03_02

import "fmt"

type Statistics struct {
	GetCount  int
	PostCount int
}

func (s *Statistics) PlusGet() {
	s.GetCount++
}

func (s *Statistics) PlusPost() {
	s.PostCount++
}

func (s *Statistics) GenStr() string {
	return fmt.Sprintf(
		"Get-request count = %d, Post-request count = %d",
		s.GetCount,
		s.PostCount,
	)
}
