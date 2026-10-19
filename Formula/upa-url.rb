class UpaUrl < Formula
  desc "WHATWG URL Standard compliant URL parser library written in C++"
  homepage "https://upa-url.github.io/docs/"
  url "https://github.com/upa-url/upa/archive/refs/tags/v2.6.0.tar.gz"
  sha256 "1c6c8184c901de81cded3c9d5efd4bc0a0732830532dda8535a39a169725606f"
  license "BSD-2-Clause"
  head "https://github.com/upa-url/upa.git", branch: "main"

  bottle do
    root_url "https://github.com/upa-url/homebrew-tap/releases/download/upa-url-2.6.0"
    sha256 cellar: :any, arm64_tahoe:  "7e148d9f649a583509ef3bd5991c1dd7d5dd48de7874a1a4223852eec520b673"
    sha256 cellar: :any, x86_64_linux: "db3b03af78457ad32f04706ddbdb4596839144f803dace2858b816a0200dceb2"
  end

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", "-DUPA_BUILD_TESTS=OFF", "-DBUILD_SHARED_LIBS=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    system "cmake", "-S", ".", "-B", "build-static", "-DUPA_BUILD_TESTS=OFF", *std_cmake_args
    system "cmake", "--build", "build-static"
    lib.install "build-static/libupa_url.a"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include "upa/url.h"
      #include <iostream>

      int main() {
          try {
              upa::url url{ "https://upa-url.github.io/" };
              url.pathname("/docs/");
              std::cout << url.href();
              return 0;
          }
          catch (...) {
              return 1;
          }
      }
    CPP

    system ENV.cxx, "test.cpp", "-std=c++17", "-o", "test",
                    "-I#{include}", "-L#{lib}", "-lupa_url"
    assert_equal "https://upa-url.github.io/docs/", shell_output("./test")
  end
end
