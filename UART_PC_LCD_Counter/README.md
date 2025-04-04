# THIẾT KẾ MẠCH TRUYỀN DỮ LIỆU UART 
***
## 1. Giới thiệu:
***
- Bộ truyền và nhận không đồng bộ UART dùng để gửi dữ liệu qua 1 đường truyền nối tiếp.
- UART bao gồm bộ phát và bộ nhận
- bộ phát cần có 1 thanh ghi dịch đặc biệt để nạp dữ liệu song song và sau đó dịch từng bit ra với 1 tốc độ xác định
- bộ nhận sẽ dịch từng bit dữ liệu vào rồi sau đs tổng hợp lại thành 1 gói dữ liệu
- ở trạng thái rỗi, đường truyền ở mức 1
- việc truyền dữ liệu bắt đầu bằng bit START (mức 0), theo sau đó là những bit dữ liệu, 1 bit parity và kết thúc bit STOP (mức 1)
- số lượng bit dữ liệu có thể là 6,7 hoặc 8
- bit parity sử dụng để phát hiện lỗi
- đối với kiểm tra chẵn lẻ thì bit parity bằng 0 khi tổng số bit 1 trong gói dữ liệu là lẻ. đối với Parity chẵn thì bit parity bằng 0 khi tổng số bit 1 là chẵn
- số lượng stop bit là 1 hoặc 2

**cấu trúc 1 byte truyền như sau:**
![Image](https://github.com/user-attachments/assets/fec7cf54-e3aa-4238-ba28-4dd94d3608e6)

- hình trên trình bay việc truyền dữ liệu 8 bit dữ liệu, không có bit parity, 1 bit stop. Bit LSB của gói dữ liệu sẽ được truyền đầu tiên.
- không có tín hiệu xung clock được truyền qua đường nối tiếp. Vì vậy trước khi bắt đầu tuyền, bộ phát và bộ thu phải thiết lập thông số tốc độ baud, số lượng bit dữ liệu, số bit stop và bit parity
- thông thường tốc độ baud là 2400, 4800, 9600, 19200

***
## 2. Thiết kế bộ nhận UART
***
### 2.1. Lấy mẫu
Hầu hết các mạch lấy mẫu sẽ dùng tốc độ lấy mẫu bằng 16 lần tốc độ baud, nghĩa là mỗi bit nối tiếp sẽ được lấy mẫu 16 lần.

Giả sử rằng ta sử dụng N bit dữ liệu và M bit stop. Mạch lấy mẫu thực hiện theo trình tự sau:
- **Bước 1:** Đợi cho đến khi xuất hiện tín hiệu START chuyển xuống mức logic “0”, sau đó khởi động bộ đếm lẫy mẫu.
- **Bước 2:** Khi đếm đến giá trị bằng 7 thì tín hiệu vào đang ở điểm giữa của bit START. Hãy xóa bộ đếm về 0 và bắt đầu khởi động lại.
- **Bước 3:** Khi bộ đếm đạt đến giá trị đếm là 15, tín hiệu vào sẽ đạt đến điểm giữa của bit dữ liệu đầu tiên (D0), ghi nhận giá trị này, dịch vào thanh ghi và khởi động lại bộ đếm.
- **Bước 4:** Lặp lại bước 3 N-1 lần để nhận những bit dữ liệu còn lại.
- **Bước 5:** Nếu có bit parity được sử dụng thì lặp lại bước 3 thêm một lần nữa để lấy bit parity.
- **Bước 6:** Lặp lại bước 3 thêm M lần để lấy được bit stop

Có thể xem như mạch lấy mẫu thực hiện chức năng của một tín hiệu xung clock. Thay vì sử dụng cạnh lên để xác định tín hiệu vào tồn tại, nó sử dụng xung lấy mẫu để ước lượng điểm giữa của mỗi bit.

Bộ nhận UART bao gồm 3 thành phần:
- UART Receiver (UR): mạch nhận dữ liệu thông qua lấy mẫu
- Baud Rate Generator (BRG): tạo ra xung lấy mẫu
- Interface Circuit (IC): mạch giao tiếp
***
### 2.2 Bộ tạo tốc độ Baud - Baud Rate Generator
Mạch này sẽ phát ra tín hiệu lấy mẫu với tần số chính xác bằng 16 lần của tốc độ baud thiết kế.

Với tốc độ baud 19200, tốc độ lấy mẫu bằng 
```c
19200*16 = 307200 lần xung mỗi giây, còn được gọi là xung tick.
```

Khi xung clock của hệ thống là 50MHz, mạch tạo tốc độ baud cần một bộ đếm mod 163 như sau:
```c
M = 50000000 / 307200 = 163
```
Bộ đếm sẽ tạo 1 xung tick sau khi đếm được 163 xung clock tần số 50MHz.

Khi xung clock của hệ thống là 100MHz, mạch tạo tốc độ baud cần một bộ đếm mod 326.

***
### 2.3. Bộ nhận UART - UART RECEIVER 
lưu đồ của mạch ASMD được trình bày như sau:
![Image](https://github.com/user-attachments/assets/d2d9fddf-7500-4379-a8a7-c967b9537316)

Hằng số D_BIT chỉ số lượng bit dữ liệu, và hằng số SB_TICK chỉ số lần tick cần cho bit stop, có thể là 16, 24 hoặc 32 tương ứng với 1, 1.5, hoặc 2 bit stop.

Trong thiết kế này thì các hằng số D_BIT và SB_TICK được gán lần lượt là 8 và 16.

- Sơ đồ bao gồm 3 trạng thái chính: start, data, stop, đại diện cho quá trình xử lý bit START, các bit dữ liệu và bit STOP.

- Tín hiệu s_tick của bộ nhận UR sẽ được nôi với ngõ ra tick của bộ BRG, có 16 lần tick cho mỗi bit. Chú ý rằng FSMD sẽ giữ nguyên trạng thái trừ khi tín hiệu stick được xác định.

Có hai bộ đếm đại diện cho thanh ghi s và n.
- Thanh ghi s sẽ lưu số lượng tick lấy mẫu và đếm đến 7 khi ở trạng thái start, đến 15 trong trạng thái data và đếm đến giá trị bằng sb_tick trong trạng thái stop.

- Thanh ghi n sẽ lưu trữ số lượng bịt được nhận trong trạng thái data.

Bit được nhận sẽ được dịch vào trong thanh ghi b.

Tín hiệu trạng thái rx_done_tick sẽ xác định một lần sau khi hoàn thành quá trình nhận.

***

### 2.4. Mạch giao tiếp - INTERFACE CIRCUIT
Trong hệ thống lớn, UART thường là một ngoại vi để phục vụ cho truyền dữ liệu nối tiếp. Hệ thống chính sẽ kiểm tra trạng thái của nó theo chu kì thời gian để nhận và xử lý dữ liệu đã được nhận.

**Mạch có 2 chức năng:**
- Chức năng thứ nhất là mạch tạo ra tín hiệu báo sẵn sàng cho việc nhận dữ liệu mới và ngăn chặn việc nhận dữ liệu lặp lại nhiều lần.
- Chức năng thứ hai là mạch cung cấp một bộ đệm cho hệ thông chính.

#### **Có 3 mạch thường được sử dụng:**
##### **a. Mạch có cờ Flip Flop (FF)**

Mạch sử dụng một cờ FF để kiểm tra xem dữ liệu mới có sẵn sàng hay chưa.

**Bộ nhận với mạch giao tiếp là mạch cờ FF**
![Image](https://github.com/user-attachments/assets/0ddeb95e-121b-461b-850f-c0d7b71de8fd)

**Mạch FF có hai ngõ vào:**

- Set_flag dùng để set cờ FF lên “1”, và clr_flag dùng để xóa cờ FF về “0”. 
- Tín hiệu rx_done_tick nối tới set_flag để set cờ FF khi có dữ liệu mới đến.

Sau khi hệ thống chính nhận dữ liệu, nó sẽ tạo ra xung xóa cờ clr_flag. 

Để kết nối với các hệ thống phía sau, ngõ ra của FF sẽ được đảo tạo thành tín hiệu rx_empty để xác định trạng thái sẵn sàng nhận dữ liệu. 

Trong mạch này, hệ thống chính sẽ nhận dữ liệu trực tiếp từ thanh ghi dịch của bộ nhận UART và không thêm bất cứ bộ đệm nào.

Nếu hệ thống ở xa bắt đầu việc truyền mới trước khi hệ thống chính nhận dữ liệu cũ, dữ liệu cũ này sẽ bị ghi đè lên và tạo ra lỗi được gọi là data overrun.

##### **b. Mạch FF có bộ đệm 1 từ**
**Bộ nhận với mạch giao tiếp là mạch cờ FF và có 1 ô nhớ đệm**
![Image](https://github.com/user-attachments/assets/4f597c3b-1e2a-4608-985a-d66e55f47294)

Khi tín hiệu rx_done_tick được xác định thì từ dữ liệu sẽ được đưa đến bộ đệm và cờ FF lên 1. Bộ nhận có thể tiếp tục hoạt động mà không cần xóa nội dung của từ dữ liệu đã được nhận trước đó.

Lỗi data overrun sẽ không xảy ra nếu hệ thống chính nhận từ dữ liệu trước khi từ dữ liệu mới đến.

##### **c. Mạch có bộ đệm FIFO**

Bộ đệm FIFO cung cấp một vùng nhớ đệm dùng để lưu dữ liệu.

Có thể được điều chỉnh để tạo ra số lượng từ dữ liệu trong bộ đệm để cung cấp quá trình xử lý của hệ thống.

Tín hiệu rx_done_tick được nối với tín hiệu wr của bộ đệm FIFO. Tín hiệu wr được xác định một xung clock và dữ liệu tương ứng sẽ được ghi vào FIFO khi một dữ liệu mới được nhận.

**Bộ nhận với mạch giao tiếp là bộ đệm FIFO**
![Image](https://github.com/user-attachments/assets/fb0bb68c-aa62-4023-8d24-57fc22853101)

Hệ thống chính sẽ lấy dữ liệu từ cổng ra của bộ đệm.

Sau khi nhận lại một từ dữ liệu, tín hiệu rd của FIFO xác định một xung clock và xóa đối tượng tương ứng.

Tín hiệu empty của FIFO có thể sử dụng để chỉ sự tồn tại của dữ liệu được nhận trong FIFO. Lỗi data overrun sẽ xảy ra khi một dữ liệu mới đến mà bộ đệm đã đầy.

## 3. Thiết kế bộ phát UART
Cấu trúc của bộ phát UART giống như bộ nhận UART.

**Bao gồm 3 thành phần:**

- UART Transmitter (UT)
- Baud Rate Generator (BRG)
- Interface Circuit (IC)

Mạch cũng tương tự như bộ nhận ngoại trừ hệ thống chính thiết lập cờ (flag) hoặc ghi vào bộ đệm FIFO và bộ phát UART sẽ xóa bộ đệm hoặc đọc bộ đệm FIFO.

Bộ phát UART là một thanh ghi dịch sẽ dịch dữ liệu ra từng bit ở một tốc độ cố định. Tốc độ này có thể được điều khiển bởi một tín hiệu tick của BRG.

Do không lấy mẫu nên tần số xung tick này nhỏ hơn 16 lần so với bộ nhận UART. Bộ phát UART dùng chung khối BRG với bộ nhận UART và sử dụng một bộ đếm nội để kiểm tra số lượng tín hiệu xung tick.

Một bịt được dịch ra mỗi lần sau khi có 16 xung tick.

Lưu đồ ASMD của bộ phát UART tương tự như bộ nhận.

Sau khi tín hiệu tx_start xác định thì FSMD sẽ nạp từ dữ liệu rồi sau đó thực hiện các trạng thái start, data, stop để dịch ra những bit tương ứng.

Khi quá trình phát hoàn thành, tín hiệu tx_done_tick sẽ được xác định bởi một xung clock. Tx_reg dùng để loại bỏ bất cứ sự cố tiềm ẩn nào.

**Bộ phát với mạch giao tiếp là bộ đệm FIFO**
![Image](https://github.com/user-attachments/assets/f385cffa-b75b-45af-95c2-efce849c5dac)

***
## 4. Thiết kế hệ thống UART hoàn chỉnh
***
Bằng cách kết hợp bộ truyền và bộ phát, ta có thể tạo ra một hệ thống UART hoàn chỉnh như hình dưới:

Tín hiệu xung **ckht** và **rst** cung cấp cho tất cả các khối.

Khối tạo tốc độ baud cung cấp tín hiệu s_tick cấp cho khối UART_RX và UART_TX.

- Khối UART_RX: Sau khi nhận được 1 byte từ ngõ vào rx sẽ truyền cho khối FIFO_RX để lưu và tín hiệu rx_done_tick điều khiển tín hiệu wr để ghi dữ liệu vào FIFO_RX.

![Image](https://github.com/user-attachments/assets/66ed8a60-9a40-4dbc-b4ca-c77e4f9e0755)

- Khối FIFO_RX: Tín hiệu trạng thái empty cho biết trạng thái khi FIFO_RX rỗng thì bằng 1, còn khi có dữ liệu ghi vào mà chưa đọc ra thì empty sẽ về 0. Khi đọc hết dữ liệu thì sẽ về 0. Tín hiệu rd của dùng để điều khiển FIFO_RX xuất dữ liệu ra ở ngõ ra r_data.

- Khối FIFO_TX: Tín hiệu trạng thái full cho biết trạng thái khi nếu FIFO_TX chưa đầy thì bằng 0, còn chứa đầy dữ liệu nhận vào mà chưa đọc ra thì empty sẽ lên 1. Tín hiệu w_data dùng để nhận dữ liệu vào FIFO_TX. Tín hiệu wr điều khiển ghi dữ liệu vào.

Khối cần truyền dữ liệu đi cần phải kiểm tra tín hiệu full nếu bằng 0 thì mới tiến hành gởi dữ liệu và tạo tín hiệu điều khiển ghi wr.

- Khối UART_TX: Tiến hành kiểm tra tín hiệu empty của FIFO_TX nếu không rỗng thì tiến hành đọc dữ liệu từ FIFO_TX để gởi đi. Tín hiệu tx_done_tick sẽ điều khiển rd để đọc dữ liệu và dữ liệu sẽ xuất ra ở r_data.


**Kết luận:** Khối điều khiển gởi dữ liệu đi sẽ giao tiếp với các tín hiệu FIFO_TX, nhận dữ liệu về sẽ giao tiếp với các tín hiệu FIFO_RX.

Từ sơ đồ khối UART hoàn chỉnh ở hình 8-8 gồm có 5 khối con bên trong được vẽ lại thành 1 khối duy nhất như hình 8-9 và tên các tín hiệu có sự thay đổi cho rõ ràng hơn.

**Khối UART hoàn chỉnh**
![Image](https://github.com/user-attachments/assets/f5673152-d97a-4642-a87b-cfe1ec98cea9)

Các tín hiệu nhận được hoặc truyền đi đều làm việc có liên quan đến bộ đệm FIFO nên các tín hiệu có thêm tên FIFO_UART, để phân biệt bên nhận và bên phát thì có thêm 2 tín hiệu là rx và tx.
