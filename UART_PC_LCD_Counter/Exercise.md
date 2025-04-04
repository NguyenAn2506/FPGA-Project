# Thiết kế mạch giao tiếp FPGA với máy tính PC qua chuẩn UART, truyền mã ASCII.

Bên FPGA có 1 mạch đếm nhị phân 8 bit, đếm xung có tần số 5Hz, hiển thị kết quả đếm trên LCD ở 3 vị trí 13, 14, 15 của hàng 2 đồng thời tự động gởi giá trị đếm nhị phân 8 bit về PC.

Nếu có dữ liệu từ PC gởi xuống thì hiển thị ở hàng 1 của LCD, các kí tự hiển thị trước đó sẽ dịch sang trái.

Bên PC nhận dữ liệu đếm hiển thị trên phần mềm và có thể gởi dữ liệu mã ASCII xuống khi nhấn các nút gửi.

Bên máy tính sử dụng phần mềm terminal để có thể truyền và nhận dữ liệu.

Thiết lập cổng COM cho đúng và tốc độ là 19200.

![Image](https://github.com/user-attachments/assets/1b73d1c7-f0c2-42ef-9bbc-7994c3ca5024)
