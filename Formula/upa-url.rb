class UpaUrl < Formula
  desc "WHATWG URL Standard compliant URL parser library written in C++"
  homepage "https://upa-url.github.io/docs/"
  url "https://github.com/upa-url/upa/archive/refs/tags/v2.2.0.tar.gz"
  sha256 "7b6d5e5774d0264ef2be0782ec3548e191ef113b34983323791a914a00de0d3a"
  license "BSD-2-Clause"
  head "https://github.com/upa-url/upa.git", branch: "main"

  bottle do
    root_url "https://github.com/upa-url/homebrew-tap/releases/download/upa-url-2.2.0"
    sha256 cellar: :any,                 arm64_sequoia: "da3e98e6aaff1f37de3ebd46d6c5653ebbb46eba6c824ebc707f8186190eb2ec"
    sha256 cellar: :any,                 ventura:       "1850793ce6171943d6685a270f1a89fee34081b791a4c3d7db6aca791e470c2f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "219992f6d9ea8676405a82ede064688440c42e8666a5ba1691220201c54b936c"
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
