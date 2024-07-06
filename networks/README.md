# BOTH ARE SAME WHEN IT COMES TO RETRANSMISSION AND DATA SEQUENCING
## Sequencing:

- Both use sequence numbers to order and manage data packets.
- Sequence numbers help in identifying the order of packets and detecting missing or out-of-order packets.

## Selective Retransmission:

- The implementation supports selective retransmission, where only the missing or incorrect packets are retransmitted.In the code we check while iterarting through the loop. In order to   demonstrate   that we are randomly alloting data packets with missing acknowledgements.
- TCP uses selective acknowledgment (SACK) to achieve a similar goal.



## In the provided code, flow control is implemented indirectly through the use of a timeout mechanism.
- The client sends a data packet to the server with a sequence number.
- After sending the packet, the client enters a select loop with a timeout.
- The select function is used to wait for either data to be available for reading (FD_SET) or a timeout to occur.
- If the select function times out, the client assumes that the acknowledgment for the sent packet was not received.
- If the received acknowledgment has the expected sequence number, the client proceeds to the next sequence number.   Otherwise, it handles the case of an incorrect acknowledgment.
- In essence, the client assumes that if it doesn't receive an acknowledgment within the specified timeout, the packet might be lost or delayed. In response to the timeout, the client retransmits the data packet. This mechanism helps control the flow of data by adjusting the rate of transmission based on the responsiveness of the server.
          