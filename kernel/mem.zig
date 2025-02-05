const Spinlock = @import("lock.zig").Spinlock;

pub const page_size: usize = 4096;

pub const BumpAllocator = struct {
    lock: Spinlock,
    heap_start: [*]u8,
    heap_size: usize,
    allocated: usize,

    pub fn init(heap_start: [*]u8, heap_size: usize) BumpAllocator {
        return .{
            .lock = Spinlock.init(),
            .heap_start = heap_start, // @TODO: ensure heap_start is aligned
            .heap_size = heap_size, // @TODO: ensure heap_size is a multiple of page_size
            .allocated = 0,
        };
    }

    pub fn allocPages(self: *BumpAllocator, pages: usize) []u8 {
        const alloc_size = pages * page_size;

        self.lock.acquire(); // do i need to disable traps before ?
        if (self.allocated + alloc_size > self.heap_size) {
            @panic("out of memory");
        }
        const heap = self.heap_start[0..self.heap_size];
        const chunk = heap[self.allocated..][0..alloc_size];
        self.allocated += alloc_size;
        self.lock.release();

        return chunk;
    }
};
