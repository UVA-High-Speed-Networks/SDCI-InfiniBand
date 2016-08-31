read_csv <- function(csv) {
	all <- read.csv(csv)

	intra_node <- subset(all, from_host == to_host)
	inter_node <- subset(all, from_host != to_host)
	intra_socket <- subset(intra_node, from_cpu == to_cpu)
	inter_socket <- subset(intra_node, from_cpu != to_cpu)

	return(c(mean(intra_node$mean), mean(inter_node$mean), mean(intra_socket$mean), mean(inter_socket$mean)))
}

plot_delay <- function(start, end, inc, eager, eager_local) {
	delays <- data.frame()

	for (size in seq(start, end, inc)) {
		csv <- list.files(pattern = paste('mpi_ping_latency_32-',
											size * 1024,
											'-100-',
											eager * 1024,
											'-',
											eager_local * 1024,
											'-.*.csv', sep = ""))[1]
		delays <- rbind(delays, c(size, read_csv(csv)))
	}

	names(delays) <- c("size", "intra_node", "inter_node", "intra_socket", "inter_socket")

	plot(delays$size, delays$inter_node, "l", ylim=c(0, max(delays$inter_node, delays$intra_node) + 5),
			xlab = "Msg. Size (KB)", ylab = "Latency (us)",
			main = sprintf("Eager Limit: %dKB; Eager Limit (Local): %dKB\n32 Tasks, 2 Nodes", eager, eager_local),
			lty = 1, col = "blue", xaxt = "n")
	points(delays$size, delays$intra_node, "l", lty = 2, col = "red")
	points(delays$size, delays$intra_socket, "l", lty = 3, col = "darkgreen")
	points(delays$size, delays$inter_socket, "l", lty = 4, col = "green")

	axis(side = 1, at = delays$size, las = 2, cex.axis = 0.5)

	legend(0, .95 * (max(delays$inter_node, delays$intra_node) + 5),
				 legend = c("Inter-node", "Intra-node (average)", "Intra-node (intra-socket)", "Intra-node (inter-socket)"),
				 lty = c(1, 2, 3, 4),
				 col = c("blue", "red", "darkgreen", "green"),
				 cex = 0.75)

	abline(v = eager, lty = 2)
	abline(v = eager_local, lty = 2)
}

plot_delay(0, 256, 4, 2, 2)
plot_delay(0, 256, 4, 4, 4)
plot_delay(0, 256, 4, 8, 8)
plot_delay(0, 256, 4, 16, 16)

#plot_delay(0, 256, 4, 32, 32)
#plot_delay(0, 256, 4, 64, 64)
#plot_delay(0, 256, 4, 64, 128)
#plot_delay(0, 256, 4, 128, 64)
#plot_delay(0, 256, 4, 128, 128)

