# BooksApp
##CI/CD

This project is configured to run test with every push (using Codemagic.io)

## Requirements and Specs
### User Stories
**Narrative #1**

As a online user, I want to be able to enter the name of a book or author in the search bar and scroll through all the results.

**Scenarios**

Given an online user

When the user enters text in the search bar and clicks on search

Then the app should display the remote results based on the input

And those books that they already read should be checked.

**Narrative #2**

As an online user, I want to be able to select a book from my previous search to add it to my list of read books.

**Scenarios**

Given an online user

When the user makes a search and selects a book from that list

Then that book is added to their "read list"

**Narrative #3**

As a user, I want to be able to access my list of read books.

**Scenarios**

Given a user

When they demand the read book list

Then the current list is fetched from local and displayed.

### Use Cases
**Load books list from remote use case**

_Data_: Search text

_Primary course_:

1. Execute the "loadBooks" command with the given input.
2. The system sends the request to the remote server.
3. The system validates the data returned by the server.
4. The system creates a list of books based on the returned result.
5. The system returns the list of books.

_Invalid data - Error course_

1. Inform the user about the error in the request.

_No connection - Error course_

1. Inform the user about the lack of internet connection.

_No books matching the input - Error course_

1. Inform the user that there are no books matching their search.

**Mark read books from books list use case**

_Data_: Books list

_Primary course_:

1. Execute the "checkReadBooksFromList" command.
2. The system retrieves the list of read books locally.
3. The system checks which books from the input are in the read list.
4. The system returns the updated list with the read status of the books.

**Mark book as read use case**

_Data_: The selected book

_Primary course_:

1. Execute the "addBookToReadList" command.
2. The system retrieves the list of read books locally.
3. The system validates that the book is not already in the list.
4. The system adds the book to the local read list.
5. The system returns a success message.

_Book already read - Error course_

1. Inform that the book was already in the list.

**Mark book as unread use case**

_Data_: The selected book

_Primary course_:

1. Execute the "removeBookFromReadList" command.
2. The system retrieves the list of read books locally.
3. The system removes the book from the read list.
4. The system returns a success message.
