#include <gtest/gtest.h>

#include <iostream>
#include <sstream>
#include <string>

// Fixture that captures std::cout output during tests
class StreamCaptureFixture : public ::testing::Test {
protected:
  void SetUp() override {
    streambuf_ = std::cout.rdbuf();   // Save original buffer
    std::cout.rdbuf(stream_.rdbuf()); // Redirect cout to stringstream
  }

  void TearDown() override {
    std::cout.rdbuf(streambuf_); // Restore original buffer
  }

  std::string GetCapturedOutput() const { return stream_.str(); }

private:
  std::ostringstream stream_;
  std::streambuf *streambuf_ = nullptr;
};

TEST_F(StreamCaptureFixture, PrintsHelloWorld) {
  std::cout << "Hello, World!" << std::endl;
  std::string output = GetCapturedOutput();

  EXPECT_NE(output.find("Hello, World!"), std::string::npos);
}
