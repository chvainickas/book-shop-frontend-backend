// frontend/src/components/Navbar.js
// navigation bar component - displays links based on authentication state

import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Navbar as BSNavbar, Nav, Container, Button } from 'react-bootstrap';
import { useAuth } from '../context/AuthContext';

const Navbar = () => {
  // get authentication state and methods from context
  const { isAuthenticated, isAdmin, user, logout } = useAuth();
  const navigate = useNavigate();

  // handle user logout - clears token and redirects to login
  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <BSNavbar bg="dark" variant="dark" expand="lg" className="mb-4">
      <Container>
        {/* brand logo/name links to homepage */}
        <BSNavbar.Brand as={Link} to="/">
          Book Shop
        </BSNavbar.Brand>
        <BSNavbar.Toggle aria-controls="basic-navbar-nav" />
        <BSNavbar.Collapse id="basic-navbar-nav">
          {/* left side navigation links */}
          <Nav className="me-auto">
            <Nav.Link as={Link} to="/">
              Browse Books
            </Nav.Link>
            {/* admin-only link to add new books */}
            {isAdmin && (
              <Nav.Link as={Link} to="/admin/books/new">
                Add Book
              </Nav.Link>
            )}
          </Nav>
          {/* right side navigation - changes based on auth state */}
          <Nav>
            {isAuthenticated ? (
              <>
                {/* authenticated user links */}
                <Nav.Link as={Link} to="/wishlist">
                  Wishlist
                </Nav.Link>
                <Nav.Link as={Link} to="/cart">
                  Cart
                </Nav.Link>
                <Nav.Link as={Link} to="/orders">
                  Orders
                </Nav.Link>
                {/* display logged in user's name */}
                <Nav.Item className="d-flex align-items-center text-light mx-2">
                  Hello, {user?.name}
                </Nav.Item>
                <Button variant="outline-light" onClick={handleLogout} size="sm">
                  Logout
                </Button>
              </>
            ) : (
              <>
                {/* unauthenticated user links */}
                <Nav.Link as={Link} to="/login">
                  Login
                </Nav.Link>
                <Nav.Link as={Link} to="/signup">
                  Sign Up
                </Nav.Link>
              </>
            )}
          </Nav>
        </BSNavbar.Collapse>
      </Container>
    </BSNavbar>
  );
};

export default Navbar;
