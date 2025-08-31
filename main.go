package main

import (
	"fmt"
	"sync"
	"time"
)

// Storage represents a simple in-memory storage for notifications
type Storage struct {
	notifications []string
	mutex         sync.Mutex
}

func (s *Storage) Save(notification string) {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	s.notifications = append(s.notifications, notification)
}

func (s *Storage) Retrieve() string {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	if len(s.notifications) > 0 {
		notification := s.notifications[0]
		s.notifications = s.notifications[1:]
		return notification
	}
	return ""
}

// Notify sends a notification to the server
func Notify(server chan<- string, message string) {
	server <- message
}

// Listen retrieves notifications from storage
func Listen(storage *Storage, client chan<- string) {
	for {
		if notification := storage.Retrieve(); notification != "" {
			client <- notification
		}
	}
}

func main() {
	// Initialize storage
	storage := &Storage{}

	// Channels for communication
	serverChan := make(chan string)
	clientChan := make(chan string)

	// Simulate step 1: Send notification to server
	go func() {
		loc, err := time.LoadLocation("Africa/Nairobi")
		if err != nil {
			loc = time.FixedZone("EAT", 3*3600)
		}
		currentTime := time.Now().In(loc)
		formattedTime := currentTime.Format("03:04 PM EAT, Jan 02, 2006")
		Notify(serverChan, "New notification created at "+formattedTime)
	}()

	// Simulate step 2: Service saves notification
	go func() {
		for msg := range serverChan {
			storage.Save(msg)
		}
	}()

	// Simulate step 3: Signal package notifies the customer
	go func() {
		if len(storage.notifications) > 0 {
			fmt.Println("Signal: New notification available")
		}
	}()

	// Simulate step 4 & 6: Retrieve and listen for notifications
	go Listen(storage, clientChan)

	// Simulate step 6: Client receives notification
	for msg := range clientChan {
		fmt.Println("Client received:", msg)
		break // Exit after receiving one notification
	}

	// Keep main goroutine alive for a moment to let other goroutines run
	fmt.Scanln()
}
