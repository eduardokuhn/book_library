// SPDX-License-Identifier: GPL-3.0

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

pragma solidity >=0.7.0 <0.9.0;

contract BookFactory is Ownable {
    Book[] public books;
    mapping(address => uint256) public borrowerToBook;
    mapping(uint256 => address[]) public bookToBorrowers;

    event NewBook(uint256 id, string name, uint256 copies);
    event AvailableBooks(Book[] onlyAvailableBooks);

    struct Book {
        // It could be an address, treating books like a NFT?
        uint256 id;
        string name;
        uint256 copies;
    }

    function addNewBook(string memory _name, uint256 _copies) public onlyOwner {
        uint256 id = books.length + 1;
        books.push(Book(id, _name, _copies));

        emit NewBook(id, _name, _copies);
    }

    function seeAvailableBooks() external view returns (Book[] memory) {
        return books;
    }

    function seeAllBorrowersFromBook(uint256 id)
        external
        view
        returns (address[] memory)
    {
        return bookToBorrowers[id - 1];
    }

    function borrowBook(uint256 id) external {
        // Because I define the id so: books.length + 1
        uint256 formattedId = id - 1;
        Book storage book = books[formattedId];

        require(
            borrowerToBook[msg.sender] == 0,
            "You already have borrowed a book"
        );
        require(
            book.copies > 0,
            "There is current no available copy of this book"
        );
        borrowerToBook[msg.sender] = book.id;
        bookToBorrowers[book.id].push(msg.sender);
        book.copies--;
    }

    function returnBook(uint256 id) external {
        // Because I define the id so: books.length + 1
        uint256 formattedId = id - 1;
        Book storage book = books[formattedId];

        require(
            borrowerToBook[msg.sender] == book.id,
            "You haven't borrowed this book yet"
        );
        borrowerToBook[msg.sender] = 0;
        book.copies++;
    }
}
