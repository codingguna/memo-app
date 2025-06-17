// // lib/screens/home/block_selection_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../services/api_service.dart';
// import '../../models/block.dart';
// import '../../core/theme/app_theme.dart';
// import 'dashboard_screen.dart';

// class BlockSelectionScreen extends StatefulWidget {
//   const BlockSelectionScreen({super.key});

//   @override
//   State<BlockSelectionScreen> createState() => _BlockSelectionScreenState();
// }

// class _BlockSelectionScreenState extends State<BlockSelectionScreen> {
//   final ApiService _apiService = ApiService();
//   List<Block> _blocks = [];
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _loadBlocks();
//   }

//   Future<void> _loadBlocks() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final hospitalId = authProvider.hospital?.id;

//       if (hospitalId != null) {
//         final response = await _apiService.getBlocks(hospitalId);
//         final List<dynamic> blocksData = response['results'] ?? response['blocks'] ?? [];
        
//         setState(() {
//           _blocks = blocksData.map((json) => Block.fromJson(json)).toList();
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to load blocks: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _selectBlock(Block block) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
//     final success = await authProvider.updateCurrentBlock(block.id, block.name);
    
//     if (success && mounted) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const DashboardScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Block'),
//         automaticallyImplyLeading: false,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 64,
//                         color: AppTheme.errorColor,
//                       ),
//                       const SizedBox(height: AppSpacing.md),
//                       Text(
//                         _error!,
//                         style: Theme.of(context).textTheme.bodyLarge,
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: AppSpacing.lg),
//                       ElevatedButton(
//                         onPressed: _loadBlocks,
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 )
//               : _blocks.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.business_outlined,
//                             size: 64,
//                             color: AppTheme.textSecondary,
//                           ),
//                           const SizedBox(height: AppSpacing.md),
//                           Text(
//                             'No blocks available',
//                             style: Theme.of(context).textTheme.titleMedium,
//                           ),
//                         ],
//                       ),
//                     )
//                   : Padding(
//                       padding: const EdgeInsets.all(AppSpacing.md),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Please select a block to continue:',
//                             style: Theme.of(context).textTheme.titleMedium,
//                           ),
//                           const SizedBox(height: AppSpacing.lg),
//                           Expanded(
//                             child: ListView.builder(
//                               itemCount: _blocks.length,
//                               itemBuilder: (context, index) {
//                                 final block = _blocks[index];
//                                 return Card(
//                                   margin: const EdgeInsets.only(bottom: AppSpacing.md),
//                                   child: ListTile(
//                                     leading: const Icon(
//                                       Icons.business,
//                                       color: AppTheme.primaryColor,
//                                     ),
//                                     title: Text(
//                                       block.name,
//                                       style: Theme.of(context).textTheme.titleMedium,
//                                     ),
//                                     subtitle: block.description != null
//                                         ? Text(block.description!)
//                                         : null,
//                                     trailing: const Icon(Icons.arrow_forward_ios),
//                                     onTap: () => _selectBlock(block),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//     );
//   }
// }