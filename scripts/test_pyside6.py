#!/usr/bin/env python3
"""
Minimal PySide6 test script to verify Qt GUI functionality.
This script creates a simple QApplication and QWidget to test that PySide6
can initialize and create GUI components in a headless environment.
"""

import sys
from PySide6.QtWidgets import QApplication, QWidget, QLabel, QVBoxLayout
from PySide6.QtCore import QTimer

def test_pyside6():
    """Test that PySide6 can create a basic GUI application."""
    print("Testing PySide6 installation...", flush=True)
    
    # Create QApplication instance
    app = QApplication(sys.argv)
    print("✓ QApplication created successfully", flush=True)
    
    # Create a simple widget
    widget = QWidget()
    widget.setWindowTitle("PySide6 Test")
    
    # Add a label
    layout = QVBoxLayout()
    label = QLabel("PySide6 is working!")
    layout.addWidget(label)
    widget.setLayout(layout)
    print("✓ QWidget and QLabel created successfully", flush=True)
    
    # Show the widget to verify full GUI stack (runs in virtual display via Xvfb)
    widget.show()
    print("✓ Widget shown successfully", flush=True)
    
    # Schedule quit before starting event loop to prevent hanging
    # Using 100ms delay to ensure widget is processed
    QTimer.singleShot(100, app.quit)
    
    # Run the event loop briefly
    app.exec()
    print("✓ Qt event loop executed successfully", flush=True)
    print("PySide6 test passed!", flush=True)
    
    # Ensure all output is flushed before exiting
    sys.stdout.flush()
    sys.stderr.flush()
    
    return 0

if __name__ == "__main__":
    sys.exit(test_pyside6())
