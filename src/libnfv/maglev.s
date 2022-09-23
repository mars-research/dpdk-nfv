; ModuleID = 'maglev.c'
source_filename = "maglev.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.maglev_kv_pair = type { i64, i64 }
%struct.rte_ether_hdr = type { %struct.rte_ether_addr, %struct.rte_ether_addr, i16 }
%struct.rte_ether_addr = type { [6 x i8] }

@ETH_HEADER_LEN = dso_local local_unnamed_addr constant i64 14, align 8
@UDP_HEADER_LEN = dso_local local_unnamed_addr constant i64 8, align 8
@IPV4_PROTO_OFFSET = dso_local local_unnamed_addr constant i64 9, align 8
@IPV4_LENGTH_OFFSET = dso_local local_unnamed_addr constant i64 2, align 8
@IPV4_CHECKSUM_OFFSET = dso_local local_unnamed_addr constant i64 10, align 8
@IPV4_SRCDST_OFFSET = dso_local local_unnamed_addr constant i64 12, align 8
@IPV4_SRCDST_LEN = dso_local local_unnamed_addr constant i64 8, align 8
@UDP_LENGTH_OFFSET = dso_local local_unnamed_addr constant i64 4, align 8
@UDP_CHECKSUM_OFFSET = dso_local local_unnamed_addr constant i64 6, align 8
@FNV_BASIS = dso_local local_unnamed_addr constant i64 -3750763034362895579, align 8
@FNV_PRIME = dso_local local_unnamed_addr constant i64 1099511628211, align 8
@packets = dso_local local_unnamed_addr global i32 0, align 4
@maglev_lookup = internal unnamed_addr global [65537 x i8] zeroinitializer, align 16
@maglev_kv_pairs = dso_local global [16777216 x %struct.maglev_kv_pair] zeroinitializer, align 4096
@.str.1 = private unnamed_addr constant [20 x i8] c"Unhandled proto %x\0A\00", align 1
@str = private unnamed_addr constant [21 x i8] c"unhandled! not ipv4?\00", align 1

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @swap_mac(%struct.rte_ether_hdr* nocapture %eth_hdr) local_unnamed_addr #0 {
entry:
  %arrayidx = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 1, i32 0, i64 0
  %0 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx, i64 8) #7
  %1 = load i8, i8* %0, align 1, !tbaa !3
  %arrayidx3 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 0, i32 0, i64 0
  %2 = call i8* @sxfi_check_deref(i8* %arrayidx3, i64 8) #7
  %3 = load i8, i8* %2, align 1, !tbaa !3
  %4 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx, i64 1) #7
  store i8 %3, i8* %4, align 1, !tbaa !3
  %5 = call i8* @sxfi_check_deref(i8* %arrayidx3, i64 1) #7
  store i8 %1, i8* %5, align 1, !tbaa !3
  %arrayidx.1 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 1, i32 0, i64 1
  %6 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.1, i64 8) #7
  %7 = load i8, i8* %6, align 1, !tbaa !3
  %arrayidx3.1 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 0, i32 0, i64 1
  %8 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx3.1, i64 8) #7
  %9 = load i8, i8* %8, align 1, !tbaa !3
  %10 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.1, i64 1) #7
  store i8 %9, i8* %10, align 1, !tbaa !3
  %11 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx3.1, i64 1) #7
  store i8 %7, i8* %11, align 1, !tbaa !3
  %arrayidx.2 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 1, i32 0, i64 2
  %12 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.2, i64 8) #7
  %13 = load i8, i8* %12, align 1, !tbaa !3
  %arrayidx3.2 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 0, i32 0, i64 2
  %14 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx3.2, i64 8) #7
  %15 = load i8, i8* %14, align 1, !tbaa !3
  %16 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.2, i64 1) #7
  store i8 %15, i8* %16, align 1, !tbaa !3
  %17 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx3.2, i64 1) #7
  store i8 %13, i8* %17, align 1, !tbaa !3
  %arrayidx.3 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 1, i32 0, i64 3
  %18 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.3, i64 8) #7
  %19 = load i8, i8* %18, align 1, !tbaa !3
  %arrayidx3.3 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 0, i32 0, i64 3
  %20 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx3.3, i64 8) #7
  %21 = load i8, i8* %20, align 1, !tbaa !3
  %22 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.3, i64 1) #7
  store i8 %21, i8* %22, align 1, !tbaa !3
  %23 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx3.3, i64 1) #7
  store i8 %19, i8* %23, align 1, !tbaa !3
  %arrayidx.4 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 1, i32 0, i64 4
  %24 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.4, i64 8) #7
  %25 = load i8, i8* %24, align 1, !tbaa !3
  %arrayidx3.4 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 0, i32 0, i64 4
  %26 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx3.4, i64 8) #7
  %27 = load i8, i8* %26, align 1, !tbaa !3
  %28 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.4, i64 1) #7
  store i8 %27, i8* %28, align 1, !tbaa !3
  %29 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx3.4, i64 1) #7
  store i8 %25, i8* %29, align 1, !tbaa !3
  %arrayidx.5 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 1, i32 0, i64 5
  %30 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.5, i64 8) #7
  %31 = load i8, i8* %30, align 1, !tbaa !3
  %arrayidx3.5 = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %eth_hdr, i64 0, i32 0, i32 0, i64 5
  %32 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx3.5, i64 8) #7
  %33 = load i8, i8* %32, align 1, !tbaa !3
  %34 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.5, i64 1) #7
  store i8 %33, i8* %34, align 1, !tbaa !3
  %35 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx3.5, i64 1) #7
  store i8 %31, i8* %35, align 1, !tbaa !3
  ret void
}

; Function Attrs: nofree nosync nounwind uwtable
define dso_local void @populate_lut(i8* nocapture %lut) local_unnamed_addr #1 {
entry:
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(65537) %lut, i8 -1, i64 65537, i1 false)
  br label %for.cond1

for.cond1:                                        ; preds = %while.end.2, %entry
  %next.sroa.0.0 = phi i64 [ 0, %entry ], [ %inc20, %while.end.2 ]
  %next.sroa.8.0 = phi i64 [ 0, %entry ], [ %inc20.1, %while.end.2 ]
  %next.sroa.13.0 = phi i64 [ 0, %entry ], [ %inc20.2, %while.end.2 ]
  %n.0 = phi i64 [ 0, %entry ], [ %inc21.2, %while.end.2 ]
  %mul.i.pn81 = mul i64 %next.sroa.0.0, 27606
  %c.0.in82 = add i64 %mul.i.pn81, 52351
  %c.083 = urem i64 %c.0.in82, 65537
  %arrayidx984 = getelementptr inbounds i8, i8* %lut, i64 %c.083
  %0 = call i8* @sxfi_check_deref(i8* %arrayidx984, i64 8) #7
  %1 = load i8, i8* %0, align 1, !tbaa !3
  %cmp1085 = icmp sgt i8 %1, -1
  br i1 %cmp1085, label %while.body, label %while.end

for.cond3:                                        ; preds = %while.end
  %mul.i.pn81.1 = mul i64 %next.sroa.8.0, 47859
  %c.0.in82.1 = add i64 %mul.i.pn81.1, 3524
  %c.083.1 = urem i64 %c.0.in82.1, 65537
  %arrayidx984.1 = getelementptr inbounds i8, i8* %lut, i64 %c.083.1
  %2 = call i8* @sxfi_check_deref(i8* %arrayidx984.1, i64 8) #7
  %3 = load i8, i8* %2, align 1, !tbaa !3
  %cmp1085.1 = icmp sgt i8 %3, -1
  br i1 %cmp1085.1, label %while.body.1, label %while.end.1

while.body:                                       ; preds = %for.cond1, %while.body
  %4 = phi i64 [ %inc13, %while.body ], [ %next.sroa.0.0, %for.cond1 ]
  %inc13 = add i64 %4, 1
  %mul.i.pn = mul i64 %inc13, 27606
  %c.0.in = add i64 %mul.i.pn, 52351
  %c.0 = urem i64 %c.0.in, 65537
  %arrayidx9 = getelementptr inbounds i8, i8* %lut, i64 %c.0
  %5 = call i8* @sxfi_check_deref(i8* %arrayidx9, i64 8) #7
  %6 = load i8, i8* %5, align 1, !tbaa !3
  %cmp10 = icmp sgt i8 %6, -1
  br i1 %cmp10, label %while.body, label %while.end, !llvm.loop !6

while.end:                                        ; preds = %while.body, %for.cond1
  %next.sroa.0.1 = phi i64 [ %next.sroa.0.0, %for.cond1 ], [ %inc13, %while.body ]
  %c.0.lcssa = phi i64 [ %c.083, %for.cond1 ], [ %c.0, %while.body ]
  %arrayidx9.le = getelementptr inbounds i8, i8* %lut, i64 %c.0.lcssa
  %7 = call i8* @sxfi_check_deref(i8* %arrayidx9.le, i64 1) #7
  store i8 0, i8* %7, align 1, !tbaa !3
  %inc20 = add i64 %next.sroa.0.1, 1
  %cmp22 = icmp eq i64 %n.0, 65536
  br i1 %cmp22, label %cleanup29, label %for.cond3

cleanup29:                                        ; preds = %while.end, %while.end.1, %while.end.2
  ret void

while.body.1:                                     ; preds = %for.cond3, %while.body.1
  %8 = phi i64 [ %inc13.1, %while.body.1 ], [ %next.sroa.8.0, %for.cond3 ]
  %inc13.1 = add i64 %8, 1
  %mul.i.pn.1 = mul i64 %inc13.1, 47859
  %c.0.in.1 = add i64 %mul.i.pn.1, 3524
  %c.0.1 = urem i64 %c.0.in.1, 65537
  %arrayidx9.1 = getelementptr inbounds i8, i8* %lut, i64 %c.0.1
  %9 = call i8* @sxfi_check_deref(i8* %arrayidx9.1, i64 8) #7
  %10 = load i8, i8* %9, align 1, !tbaa !3
  %cmp10.1 = icmp sgt i8 %10, -1
  br i1 %cmp10.1, label %while.body.1, label %while.end.1, !llvm.loop !6

while.end.1:                                      ; preds = %while.body.1, %for.cond3
  %next.sroa.8.2 = phi i64 [ %next.sroa.8.0, %for.cond3 ], [ %inc13.1, %while.body.1 ]
  %c.0.lcssa.1 = phi i64 [ %c.083.1, %for.cond3 ], [ %c.0.1, %while.body.1 ]
  %arrayidx9.le.1 = getelementptr inbounds i8, i8* %lut, i64 %c.0.lcssa.1
  %11 = call i8* @sxfi_check_deref(i8* %arrayidx9.le.1, i64 1) #7
  store i8 1, i8* %11, align 1, !tbaa !3
  %inc20.1 = add i64 %next.sroa.8.2, 1
  %cmp22.1 = icmp eq i64 %n.0, 65535
  br i1 %cmp22.1, label %cleanup29, label %for.cond3.1

for.cond3.1:                                      ; preds = %while.end.1
  %mul.i.pn81.2 = mul i64 %next.sroa.13.0, 59205
  %c.0.in82.2 = add i64 %mul.i.pn81.2, 44417
  %c.083.2 = urem i64 %c.0.in82.2, 65537
  %arrayidx984.2 = getelementptr inbounds i8, i8* %lut, i64 %c.083.2
  %12 = call i8* @sxfi_check_deref(i8* %arrayidx984.2, i64 8) #7
  %13 = load i8, i8* %12, align 1, !tbaa !3
  %cmp1085.2 = icmp sgt i8 %13, -1
  br i1 %cmp1085.2, label %while.body.2, label %while.end.2

while.body.2:                                     ; preds = %for.cond3.1, %while.body.2
  %14 = phi i64 [ %inc13.2, %while.body.2 ], [ %next.sroa.13.0, %for.cond3.1 ]
  %inc13.2 = add i64 %14, 1
  %mul.i.pn.2 = mul i64 %inc13.2, 59205
  %c.0.in.2 = add i64 %mul.i.pn.2, 44417
  %c.0.2 = urem i64 %c.0.in.2, 65537
  %arrayidx9.2 = getelementptr inbounds i8, i8* %lut, i64 %c.0.2
  %15 = call i8* @sxfi_check_deref(i8* %arrayidx9.2, i64 8) #7
  %16 = load i8, i8* %15, align 1, !tbaa !3
  %cmp10.2 = icmp sgt i8 %16, -1
  br i1 %cmp10.2, label %while.body.2, label %while.end.2, !llvm.loop !6

while.end.2:                                      ; preds = %while.body.2, %for.cond3.1
  %next.sroa.13.2 = phi i64 [ %next.sroa.13.0, %for.cond3.1 ], [ %inc13.2, %while.body.2 ]
  %c.0.lcssa.2 = phi i64 [ %c.083.2, %for.cond3.1 ], [ %c.0.2, %while.body.2 ]
  %arrayidx9.le.2 = getelementptr inbounds i8, i8* %lut, i64 %c.0.lcssa.2
  %17 = call i8* @sxfi_check_deref(i8* %arrayidx9.le.2, i64 1) #7
  store i8 2, i8* %17, align 1, !tbaa !3
  %inc20.2 = add i64 %next.sroa.13.2, 1
  %inc21.2 = add i64 %n.0, 3
  %cmp22.2 = icmp eq i64 %inc21.2, 65537
  br i1 %cmp22.2, label %cleanup29, label %for.cond1
}

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @maglev_hashmap_insert(i64 %key, i64 %value) local_unnamed_addr #0 {
entry:
  %sext = shl i64 %key, 56
  %conv.i.i = ashr exact i64 %sext, 56
  %xor.i.i = xor i64 %conv.i.i, -5808590958014384161
  %mul.i.i.1 = mul i64 %xor.i.i, 1099511628211
  %0 = shl i64 %key, 48
  %conv.i.i.1 = ashr i64 %0, 56
  %xor.i.i.1 = xor i64 %mul.i.i.1, %conv.i.i.1
  %mul.i.i.2 = mul i64 %xor.i.i.1, 1099511628211
  %1 = shl i64 %key, 40
  %conv.i.i.2 = ashr i64 %1, 56
  %xor.i.i.2 = xor i64 %mul.i.i.2, %conv.i.i.2
  %mul.i.i.3 = mul i64 %xor.i.i.2, 1099511628211
  %2 = shl i64 %key, 32
  %conv.i.i.3 = ashr i64 %2, 56
  %xor.i.i.3 = xor i64 %mul.i.i.3, %conv.i.i.3
  %mul.i.i.4 = mul i64 %xor.i.i.3, 1099511628211
  %3 = shl i64 %key, 24
  %conv.i.i.4 = ashr i64 %3, 56
  %xor.i.i.4 = xor i64 %mul.i.i.4, %conv.i.i.4
  %mul.i.i.5 = mul i64 %xor.i.i.4, 1099511628211
  %4 = shl i64 %key, 16
  %conv.i.i.5 = ashr i64 %4, 56
  %xor.i.i.5 = xor i64 %mul.i.i.5, %conv.i.i.5
  %mul.i.i.6 = mul i64 %xor.i.i.5, 1099511628211
  %5 = shl i64 %key, 8
  %conv.i.i.6 = ashr i64 %5, 56
  %xor.i.i.6 = xor i64 %mul.i.i.6, %conv.i.i.6
  %mul.i.i.7 = mul i64 %xor.i.i.6, 1099511628211
  %conv.i.i.7 = ashr i64 %key, 56
  %xor.i.i.7 = xor i64 %mul.i.i.7, %conv.i.i.7
  br label %for.body

for.cond:                                         ; preds = %for.body
  %inc = add nuw nsw i64 %i.018, 1
  %exitcond.not = icmp eq i64 %inc, 16777216
  br i1 %exitcond.not, label %cleanup8, label %for.body, !llvm.loop !8

for.body:                                         ; preds = %entry, %for.cond
  %i.018 = phi i64 [ 0, %entry ], [ %inc, %for.cond ]
  %add = add i64 %i.018, %xor.i.i.7
  %rem = and i64 %add, 16777215
  %key1 = getelementptr inbounds [16777216 x %struct.maglev_kv_pair], [16777216 x %struct.maglev_kv_pair]* @maglev_kv_pairs, i64 0, i64 %rem, i32 0
  %6 = bitcast i64* %key1 to i8*
  %7 = call i8* @sxfi_check_deref(i8* nonnull %6, i64 8) #7
  %8 = bitcast i8* %7 to i64*
  %9 = load i64, i64* %8, align 16, !tbaa !9
  %cmp2 = icmp eq i64 %9, %key
  %cmp4 = icmp eq i64 %9, 0
  %or.cond = or i1 %cmp2, %cmp4
  br i1 %or.cond, label %if.then, label %for.cond

if.then:                                          ; preds = %for.body
  %10 = bitcast i64* %key1 to i8*
  %11 = call i8* @sxfi_check_deref(i8* nonnull %10, i64 8) #7
  %12 = bitcast i8* %11 to i64*
  store i64 %key, i64* %12, align 16, !tbaa !9
  %value6 = getelementptr inbounds [16777216 x %struct.maglev_kv_pair], [16777216 x %struct.maglev_kv_pair]* @maglev_kv_pairs, i64 0, i64 %rem, i32 1
  %13 = bitcast i64* %value6 to i8*
  %14 = call i8* @sxfi_check_deref(i8* nonnull %13, i64 8) #7
  %15 = bitcast i8* %14 to i64*
  store i64 %value, i64* %15, align 8, !tbaa !12
  br label %cleanup8

cleanup8:                                         ; preds = %for.cond, %if.then
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind readonly uwtable
define dso_local %struct.maglev_kv_pair* @maglev_hashmap_get(i64 %key) local_unnamed_addr #3 {
entry:
  %sext = shl i64 %key, 56
  %conv.i.i = ashr exact i64 %sext, 56
  %xor.i.i = xor i64 %conv.i.i, -5808590958014384161
  %mul.i.i.1 = mul i64 %xor.i.i, 1099511628211
  %0 = shl i64 %key, 48
  %conv.i.i.1 = ashr i64 %0, 56
  %xor.i.i.1 = xor i64 %mul.i.i.1, %conv.i.i.1
  %mul.i.i.2 = mul i64 %xor.i.i.1, 1099511628211
  %1 = shl i64 %key, 40
  %conv.i.i.2 = ashr i64 %1, 56
  %xor.i.i.2 = xor i64 %mul.i.i.2, %conv.i.i.2
  %mul.i.i.3 = mul i64 %xor.i.i.2, 1099511628211
  %2 = shl i64 %key, 32
  %conv.i.i.3 = ashr i64 %2, 56
  %xor.i.i.3 = xor i64 %mul.i.i.3, %conv.i.i.3
  %mul.i.i.4 = mul i64 %xor.i.i.3, 1099511628211
  %3 = shl i64 %key, 24
  %conv.i.i.4 = ashr i64 %3, 56
  %xor.i.i.4 = xor i64 %mul.i.i.4, %conv.i.i.4
  %mul.i.i.5 = mul i64 %xor.i.i.4, 1099511628211
  %4 = shl i64 %key, 16
  %conv.i.i.5 = ashr i64 %4, 56
  %xor.i.i.5 = xor i64 %mul.i.i.5, %conv.i.i.5
  %mul.i.i.6 = mul i64 %xor.i.i.5, 1099511628211
  %5 = shl i64 %key, 8
  %conv.i.i.6 = ashr i64 %5, 56
  %xor.i.i.6 = xor i64 %mul.i.i.6, %conv.i.i.6
  %mul.i.i.7 = mul i64 %xor.i.i.6, 1099511628211
  %conv.i.i.7 = ashr i64 %key, 56
  %xor.i.i.7 = xor i64 %mul.i.i.7, %conv.i.i.7
  br label %for.body

for.cond:                                         ; preds = %cleanup
  %inc = add nuw nsw i64 %i.023, 1
  %exitcond.not = icmp eq i64 %inc, 16777216
  br i1 %exitcond.not, label %cleanup8, label %for.body, !llvm.loop !13

for.body:                                         ; preds = %entry, %for.cond
  %i.023 = phi i64 [ 0, %entry ], [ %inc, %for.cond ]
  %add = add i64 %i.023, %xor.i.i.7
  %rem = and i64 %add, 16777215
  %arrayidx = getelementptr inbounds [16777216 x %struct.maglev_kv_pair], [16777216 x %struct.maglev_kv_pair]* @maglev_kv_pairs, i64 0, i64 %rem
  %6 = bitcast %struct.maglev_kv_pair* %arrayidx to i8*
  %7 = call i8* @sxfi_check_deref(i8* nonnull %6, i64 8) #7
  %8 = bitcast i8* %7 to i64*
  %9 = load i64, i64* %8, align 16, !tbaa !9
  %cmp2 = icmp eq i64 %9, 0
  br i1 %cmp2, label %cleanup8, label %cleanup

cleanup:                                          ; preds = %for.body
  %cmp4 = icmp eq i64 %9, %key
  br i1 %cmp4, label %cleanup8, label %for.cond

cleanup8:                                         ; preds = %for.body, %for.cond, %cleanup
  %spec.select = phi %struct.maglev_kv_pair* [ null, %for.body ], [ null, %for.cond ], [ %arrayidx, %cleanup ]
  ret %struct.maglev_kv_pair* %spec.select
}

; Function Attrs: nofree nounwind uwtable
define dso_local i64 @maglev_process_frame(%struct.rte_ether_hdr* nocapture readonly %frame) local_unnamed_addr #4 {
entry:
  %arrayidx.i = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %frame, i64 0, i32 0, i32 0, i64 14
  %0 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx.i, i64 8) #7
  %1 = load i8, i8* %0, align 1, !tbaa !3
  %.mask.i = and i8 %1, -16
  %cmp2.not.i = icmp eq i8 %.mask.i, 64
  br i1 %cmp2.not.i, label %if.end5.i, label %if.then4.i

if.then4.i:                                       ; preds = %entry
  %puts.i = tail call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([21 x i8], [21 x i8]* @str, i64 0, i64 0)) #8
  br label %if.end4

if.end5.i:                                        ; preds = %entry
  %arrayidx6.i = getelementptr inbounds %struct.rte_ether_hdr, %struct.rte_ether_hdr* %frame, i64 0, i32 0, i32 0, i64 23
  %2 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx6.i, i64 8) #7
  %3 = load i8, i8* %2, align 1, !tbaa !3
  switch i8 %3, label %if.then14.i [
    i8 6, label %if.end4
    i8 17, label %if.end4
  ]

if.then14.i:                                      ; preds = %if.end5.i
  %conv7.i = sext i8 %3 to i32
  %call16.i = tail call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([20 x i8], [20 x i8]* @.str.1, i64 0, i64 0), i32 %conv7.i) #8
  br label %if.end4

if.end4:                                          ; preds = %if.end5.i, %if.end5.i, %if.then14.i, %if.then4.i
  ret i64 -1
}

; Function Attrs: nofree nosync nounwind uwtable
define dso_local void @maglev_init() local_unnamed_addr #1 {
entry:
  tail call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 16 dereferenceable(65537) getelementptr inbounds ([65537 x i8], [65537 x i8]* @maglev_lookup, i64 0, i64 0), i8 -1, i64 65537, i1 false) #8
  br label %for.cond1.i

for.cond1.i:                                      ; preds = %while.end.2.i, %entry
  %next.sroa.0.0.i = phi i64 [ 0, %entry ], [ %inc20.i, %while.end.2.i ]
  %next.sroa.8.0.i = phi i64 [ 0, %entry ], [ %inc20.1.i, %while.end.2.i ]
  %next.sroa.13.0.i = phi i64 [ 0, %entry ], [ %inc20.2.i, %while.end.2.i ]
  %n.0.i = phi i64 [ 0, %entry ], [ %inc21.2.i, %while.end.2.i ]
  %mul.i.pn81.i = mul i64 %next.sroa.0.0.i, 27606
  %c.0.in82.i = add i64 %mul.i.pn81.i, 52351
  %c.083.i = urem i64 %c.0.in82.i, 65537
  %arrayidx984.i = getelementptr inbounds [65537 x i8], [65537 x i8]* @maglev_lookup, i64 0, i64 %c.083.i
  %0 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx984.i, i64 8) #7
  %1 = load i8, i8* %0, align 1, !tbaa !3
  %cmp1085.i = icmp sgt i8 %1, -1
  br i1 %cmp1085.i, label %while.body.i, label %for.cond3.i

for.cond3.i:                                      ; preds = %while.body.i, %for.cond1.i
  %next.sroa.0.1.i = phi i64 [ %next.sroa.0.0.i, %for.cond1.i ], [ %inc13.i, %while.body.i ]
  %c.0.lcssa.i = phi i64 [ %c.083.i, %for.cond1.i ], [ %c.0.i, %while.body.i ]
  %arrayidx9.le.i = getelementptr inbounds [65537 x i8], [65537 x i8]* @maglev_lookup, i64 0, i64 %c.0.lcssa.i
  %2 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx9.le.i, i64 1) #7
  store i8 0, i8* %2, align 1, !tbaa !3
  %inc20.i = add i64 %next.sroa.0.1.i, 1
  %mul.i.pn81.1.i = mul i64 %next.sroa.8.0.i, 47859
  %c.0.in82.1.i = add i64 %mul.i.pn81.1.i, 3524
  %c.083.1.i = urem i64 %c.0.in82.1.i, 65537
  %arrayidx984.1.i = getelementptr inbounds [65537 x i8], [65537 x i8]* @maglev_lookup, i64 0, i64 %c.083.1.i
  %3 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx984.1.i, i64 8) #7
  %4 = load i8, i8* %3, align 1, !tbaa !3
  %cmp1085.1.i = icmp sgt i8 %4, -1
  br i1 %cmp1085.1.i, label %while.body.1.i, label %while.end.1.i

while.body.i:                                     ; preds = %for.cond1.i, %while.body.i
  %5 = phi i64 [ %inc13.i, %while.body.i ], [ %next.sroa.0.0.i, %for.cond1.i ]
  %inc13.i = add i64 %5, 1
  %mul.i.pn.i = mul i64 %inc13.i, 27606
  %c.0.in.i = add i64 %mul.i.pn.i, 52351
  %c.0.i = urem i64 %c.0.in.i, 65537
  %arrayidx9.i = getelementptr inbounds [65537 x i8], [65537 x i8]* @maglev_lookup, i64 0, i64 %c.0.i
  %6 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx9.i, i64 8) #7
  %7 = load i8, i8* %6, align 1, !tbaa !3
  %cmp10.i = icmp sgt i8 %7, -1
  br i1 %cmp10.i, label %while.body.i, label %for.cond3.i, !llvm.loop !6

while.body.1.i:                                   ; preds = %for.cond3.i, %while.body.1.i
  %8 = phi i64 [ %inc13.1.i, %while.body.1.i ], [ %next.sroa.8.0.i, %for.cond3.i ]
  %inc13.1.i = add i64 %8, 1
  %mul.i.pn.1.i = mul i64 %inc13.1.i, 47859
  %c.0.in.1.i = add i64 %mul.i.pn.1.i, 3524
  %c.0.1.i = urem i64 %c.0.in.1.i, 65537
  %arrayidx9.1.i = getelementptr inbounds [65537 x i8], [65537 x i8]* @maglev_lookup, i64 0, i64 %c.0.1.i
  %9 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx9.1.i, i64 8) #7
  %10 = load i8, i8* %9, align 1, !tbaa !3
  %cmp10.1.i = icmp sgt i8 %10, -1
  br i1 %cmp10.1.i, label %while.body.1.i, label %while.end.1.i, !llvm.loop !6

while.end.1.i:                                    ; preds = %while.body.1.i, %for.cond3.i
  %next.sroa.8.2.i = phi i64 [ %next.sroa.8.0.i, %for.cond3.i ], [ %inc13.1.i, %while.body.1.i ]
  %c.0.lcssa.1.i = phi i64 [ %c.083.1.i, %for.cond3.i ], [ %c.0.1.i, %while.body.1.i ]
  %arrayidx9.le.1.i = getelementptr inbounds [65537 x i8], [65537 x i8]* @maglev_lookup, i64 0, i64 %c.0.lcssa.1.i
  %11 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx9.le.1.i, i64 1) #7
  store i8 1, i8* %11, align 1, !tbaa !3
  %inc20.1.i = add i64 %next.sroa.8.2.i, 1
  %cmp22.1.i = icmp eq i64 %n.0.i, 65535
  br i1 %cmp22.1.i, label %populate_lut.exit, label %for.cond3.1.i

for.cond3.1.i:                                    ; preds = %while.end.1.i
  %mul.i.pn81.2.i = mul i64 %next.sroa.13.0.i, 59205
  %c.0.in82.2.i = add i64 %mul.i.pn81.2.i, 44417
  %c.083.2.i = urem i64 %c.0.in82.2.i, 65537
  %arrayidx984.2.i = getelementptr inbounds [65537 x i8], [65537 x i8]* @maglev_lookup, i64 0, i64 %c.083.2.i
  %12 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx984.2.i, i64 8) #7
  %13 = load i8, i8* %12, align 1, !tbaa !3
  %cmp1085.2.i = icmp sgt i8 %13, -1
  br i1 %cmp1085.2.i, label %while.body.2.i, label %while.end.2.i

while.body.2.i:                                   ; preds = %for.cond3.1.i, %while.body.2.i
  %14 = phi i64 [ %inc13.2.i, %while.body.2.i ], [ %next.sroa.13.0.i, %for.cond3.1.i ]
  %inc13.2.i = add i64 %14, 1
  %mul.i.pn.2.i = mul i64 %inc13.2.i, 59205
  %c.0.in.2.i = add i64 %mul.i.pn.2.i, 44417
  %c.0.2.i = urem i64 %c.0.in.2.i, 65537
  %arrayidx9.2.i = getelementptr inbounds [65537 x i8], [65537 x i8]* @maglev_lookup, i64 0, i64 %c.0.2.i
  %15 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx9.2.i, i64 8) #7
  %16 = load i8, i8* %15, align 1, !tbaa !3
  %cmp10.2.i = icmp sgt i8 %16, -1
  br i1 %cmp10.2.i, label %while.body.2.i, label %while.end.2.i, !llvm.loop !6

while.end.2.i:                                    ; preds = %while.body.2.i, %for.cond3.1.i
  %next.sroa.13.2.i = phi i64 [ %next.sroa.13.0.i, %for.cond3.1.i ], [ %inc13.2.i, %while.body.2.i ]
  %c.0.lcssa.2.i = phi i64 [ %c.083.2.i, %for.cond3.1.i ], [ %c.0.2.i, %while.body.2.i ]
  %arrayidx9.le.2.i = getelementptr inbounds [65537 x i8], [65537 x i8]* @maglev_lookup, i64 0, i64 %c.0.lcssa.2.i
  %17 = call i8* @sxfi_check_deref(i8* nonnull %arrayidx9.le.2.i, i64 1) #7
  store i8 2, i8* %17, align 1, !tbaa !3
  %inc20.2.i = add i64 %next.sroa.13.2.i, 1
  %inc21.2.i = add nuw nsw i64 %n.0.i, 3
  br label %for.cond1.i

populate_lut.exit:                                ; preds = %while.end.1.i
  ret void
}

; Function Attrs: nofree nounwind
declare dso_local noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #5

; Function Attrs: nofree nounwind
declare noundef i32 @puts(i8* nocapture noundef readonly) local_unnamed_addr #6

declare i8* @sxfi_check_deref(i8*, i64)

attributes #0 = { nofree norecurse nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { argmemonly mustprogress nofree nounwind willreturn writeonly }
attributes #3 = { nofree norecurse nosync nounwind readonly uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nofree nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nofree nounwind }
attributes #7 = { alwaysinline nounwind }
attributes #8 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"clang version 13.0.0 (git@github.com:mars-research/llvm-project-13.x.git 1eec89b0ab27617a059c1277b6ac86e573f81315)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = !{!10, !11, i64 0}
!10 = !{!"maglev_kv_pair", !11, i64 0, !11, i64 8}
!11 = !{!"long", !4, i64 0}
!12 = !{!10, !11, i64 8}
!13 = distinct !{!13, !7}
